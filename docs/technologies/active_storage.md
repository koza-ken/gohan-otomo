# 📁 Active Storage + 画像処理 - 完全復習ガイド

## 概要

**Active Storage** は Rails 6以降の標準ファイルアップロード機能。
Cloudinary と組み合わせて、堅牢な画像アップロード・処理・表示システムを構築しました。

### 基本的な特徴
- **Rails 標準**: Rails に組み込まれた公式ファイル管理システム
- **クラウド対応**: S3、GCS、Azure、Cloudinary など対応
- **画像処理**: variant による動的リサイズ・最適化
- **セキュリティ**: ファイル形式・サイズ制限機能

## このアプリでの役割

### 🎯 **なぜActive Storageを選択したのか**

#### **1. Rails 7 標準の安心感**
- **公式サポート**: Rails チームによる継続的メンテナンス
- **アップグレード対応**: Rails バージョンアップに追随
- **ドキュメント充実**: 豊富な公式ドキュメント

#### **2. 他選択肢との比較**
```ruby
# CarrierWave（従来の人気gem）
# ❌ Rails 標準でない
# ❌ 設定が複雑
# ❌ Rails 7 との相性問題

# Paperclip（廃止予定）
# ❌ メンテナンス終了
# ❌ セキュリティリスク

# Active Storage（Rails 標準）
# ✅ Rails 標準で安心
# ✅ シンプルな設定
# ✅ variant機能充実
```

### 💡 **ハイブリッド画像システム**

このアプリでは、Active Storage を中心とした3段階フォールバック画像システムを構築：

1. **Active Storage画像**（最優先） → ユーザーアップロード
2. **外部URL画像**（次優先） → 楽天API経由
3. **プレースホルダー**（最終手段） → 🍚アイコン

## 実装内容

### 🔧 **1. モデル設定**

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  # Active Storage の画像添付
  has_one_attached :image

  # 画像バリデーション（セキュリティ重要）
  validates :image, content_type: {
    in: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    message: 'はJPEG, PNG, GIF, WebP形式である必要があります'
  }, size: {
    less_than: 10.megabytes,
    message: 'は10MB未満である必要があります'
  }

  # ハイブリッド画像表示（エラーハンドリング付き）
  def display_image(size = :medium)
    if image.attached?
      begin
        case size.to_sym
        when :thumbnail
          thumbnail_image
        when :medium, :large
          medium_image
        else
          medium_image
        end
      rescue ActiveStorage::IntegrityError => e
        Rails.logger.warn "ActiveStorage error for post #{id}: #{e.message}"
        # エラー時は外部URLにフォールバック
        image_url.presence
      end
    else
      image_url.presence
    end
  end

  # Variant生成（vips使用）
  def thumbnail_image
    image.variant(resize_to_fill: [400, 300])
  rescue ActiveStorage::IntegrityError => e
    Rails.logger.warn "Thumbnail variant error for post #{id}: #{e.message}"
    nil
  end

  def medium_image
    image.variant(resize_to_fill: [800, 600])
  rescue ActiveStorage::IntegrityError => e
    Rails.logger.warn "Medium variant error for post #{id}: #{e.message}"
    nil
  end

  # 画像存在チェック
  def has_image?
    image.attached? || image_url.present?
  end
end
```

### ⚙️ **2. 設定ファイル**

#### **storage.yml（Cloudinary設定）**
```yaml
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

cloudinary:
  service: Cloudinary    # ← この行が重要（抜けるとエラー）
  cloud_name: <%= Rails.application.credentials.dig(:cloudinary, :cloud_name) %>
  api_key: <%= Rails.application.credentials.dig(:cloudinary, :api_key) %>
  api_secret: <%= Rails.application.credentials.dig(:cloudinary, :api_secret) %>
```

#### **環境別設定**
```ruby
# config/environments/development.rb
config.active_storage.variant_processor = :vips
config.active_storage.service = :local

# config/environments/production.rb
config.active_storage.variant_processor = :vips
config.active_storage.service = :cloudinary
```

### 🎨 **3. ビューでの表示**

#### **投稿フォーム**
```erb
<!-- app/views/posts/_form.html.erb -->
<!-- ファイル選択UI -->
<div data-unified-preview-target="fileSection" class="hidden mb-6">
  <%= f.label :image, "画像アップロード", class: "block text-sm font-medium text-orange-700 mb-2" %>

  <!-- 現在の画像表示（編集時） -->
  <% if post.persisted? && post.image.attached? %>
    <div class="mb-4 p-3 bg-orange-50 rounded-lg">
      <%= image_tag post.thumbnail_image, class: "w-16 h-16 object-cover rounded-lg" %>
      <p class="text-sm font-medium"><%= post.image.filename %></p>
      <p class="text-xs"><%= number_to_human_size(post.image.byte_size) %></p>
    </div>
  <% end %>

  <!-- ファイル選択 -->
  <%= f.file_field :image,
                   accept: "image/*",
                   class: "sr-only",
                   data: {
                     "unified-preview-target": "fileInput",
                     "action": "change->unified-preview#updateFilePreview"
                   } %>
</div>
```

#### **画像表示（共通）**
```erb
<!-- app/views/shared/_post_image.html.erb -->
<% if post.has_image? %>
  <% begin %>
    <%= image_tag post.display_image(size),
                  class: css_classes,
                  alt: post.title,
                  loading: "lazy" %>
  <% rescue ActiveStorage::IntegrityError => e %>
    <% Rails.logger.warn "Image display error for post #{post.id}: #{e.message}" %>
    <!-- プレースホルダー表示 -->
    <div class="<%= css_classes %> bg-orange-100 flex items-center justify-center">
      <span class="text-4xl">🍚</span>
    </div>
  <% end %>
<% else %>
  <div class="<%= css_classes %> bg-orange-100 flex items-center justify-center">
    <span class="text-4xl">🍚</span>
  </div>
<% end %>
```

### 🔒 **4. セキュリティ対策**

#### **ファイル形式制限**
```ruby
validates :image, content_type: {
  in: %w[image/jpeg image/png image/gif image/webp],
  message: 'は画像ファイル（JPEG/PNG/GIF/WebP）である必要があります'
}
```

#### **ファイルサイズ制限**
```ruby
validates :image, size: {
  less_than: 10.megabytes,
  message: 'は10MB未満である必要があります'
}
```

#### **MIME タイプチェック**
```ruby
# Active Storage は自動で MIME タイプをチェック
# ファイル拡張子の偽装を防止
```

## 学習ポイント

### 🎯 **1. Active Storage の基本パターン**

#### **添付設定**
```ruby
# 単一ファイル
has_one_attached :image

# 複数ファイル
has_many_attached :images

# 使用方法
post.image.attach(params[:image])    # 添付
post.image.attached?                 # 存在確認
post.image.purge                     # 削除
```

#### **Variant（動的リサイズ）**
```ruby
# 基本的なvariant
image.variant(resize_to_limit: [300, 300])

# 高度なvariant（vips使用）
image.variant(
  resize_to_fill: [400, 300],   # サイズ指定
  format: :webp,                # 形式変換
  quality: 85                   # 品質指定
)
```

### 🛡️ **2. エラーハンドリングの重要性**

#### **IntegrityError対策**
```ruby
def safe_image_display
  begin
    image.variant(resize_to_fill: [400, 300])
  rescue ActiveStorage::IntegrityError => e
    Rails.logger.warn "Image processing error: #{e.message}"
    # フォールバック処理
    default_image_or_placeholder
  end
end
```

**発生原因**:
- ファイルの破損・不整合
- Cloudinary との同期問題
- vips 処理エラー
- ネットワーク問題

### 🔧 **3. vips vs ImageMagick**

#### **vips選択の理由**
```ruby
# ImageMagick（従来）
# ❌ メモリ使用量大
# ❌ 処理速度遅い
# ❌ セキュリティ脆弱性

# vips（推奨）
# ✅ 高速処理
# ✅ 低メモリ使用量
# ✅ 豊富な画像形式対応
# ✅ Rails 7 推奨
```

#### **Docker環境構築**
```dockerfile
# Dockerfile
RUN apt-get update && apt-get install -y \
  libvips42 \
  libvips-dev \
  libvips-tools
```

### 🧪 **4. テスト戦略**

#### **FactoryBot設定**
```ruby
# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { "テスト商品" }
    description { "美味しいです" }

    # 軽量なテスト用添付
    trait :with_attached_image do
      after(:build) do |post|
        post.image.attach(
          io: StringIO.new("fake image data"),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
```

#### **Model Spec**
```ruby
# spec/models/post_spec.rb
RSpec.describe Post, type: :model do
  describe 'Active Storage' do
    it '画像を添付できる' do
      post = create(:post)
      file = fixture_file_upload('test_image.jpg', 'image/jpeg')

      post.image.attach(file)

      expect(post.image.attached?).to be true
      expect(post.image.filename).to eq 'test_image.jpg'
    end
  end

  describe '画像variant生成' do
    let(:post) { create(:post, :with_attached_image) }

    it 'thumbnail_imageでサムネイル生成' do
      expect(post.thumbnail_image).to be_present
    end

    it 'medium_imageで中サイズ生成' do
      expect(post.medium_image).to be_present
    end
  end

  describe '#display_image' do
    context 'Active Storage画像がある場合' do
      let(:post) { create(:post, :with_attached_image) }

      it 'thumbnail サイズを返す' do
        result = post.display_image(:thumbnail)
        expect(result).to eq post.thumbnail_image
      end
    end

    context '外部URL画像がある場合' do
      let(:post) { create(:post, image_url: 'https://example.com/image.jpg') }

      it 'image_url を返す' do
        result = post.display_image
        expect(result).to eq 'https://example.com/image.jpg'
      end
    end
  end
end
```

#### **System Spec**
```ruby
# spec/system/posts_spec.rb
RSpec.describe "Posts", type: :system do
  it '画像をアップロードして投稿できる' do
    # ファイル選択方式を選択
    choose "post_image_source_file"

    # 画像ファイルを添付
    attach_file "post_image", Rails.root.join("spec/fixtures/files/test_image.jpg")

    click_button "投稿する"

    expect(page).to have_content("投稿が作成されました")
  end
end
```

## 関連ファイル

### 🔧 **設定ファイル**
```
config/
├── storage.yml                     # ストレージ設定
├── environments/
│   ├── development.rb              # 開発環境設定
│   ├── production.rb               # 本番環境設定
│   └── test.rb                     # テスト環境設定
└── credentials.yml.enc             # Cloudinary認証情報
```

### 📁 **モデルファイル**
```
app/models/
└── post.rb                         # Active Storage設定・画像処理

app/views/shared/
└── _post_image.html.erb            # 画像表示共通パーシャル
```

### 🧪 **テストファイル**
```
spec/
├── factories/posts.rb              # FactoryBot設定
├── fixtures/files/                 # テスト用画像ファイル
├── models/post_spec.rb             # モデルテスト
└── system/posts_spec.rb            # 統合テスト
```

### 🐳 **環境構築**
```
Dockerfile
├── vips ライブラリインストール
└── 画像処理環境構築

docker-compose.yml
└── 開発環境コンテナ設定
```

## 他プロジェクトでの応用

### 🔄 **汎用的なパターン**

#### **1. 基本的なActive Storage実装**
```ruby
class Document < ApplicationRecord
  has_one_attached :file

  validates :file, content_type: {
    in: ['application/pdf', 'text/plain'],
    message: 'はPDFまたはテキストファイルである必要があります'
  }
end
```

#### **2. 複数ファイル対応**
```ruby
class Gallery < ApplicationRecord
  has_many_attached :images

  validates :images, limit: { max: 10 }
end
```

#### **3. エラーハンドリングパターン**
```ruby
def safe_variant_generation
  begin
    image.variant(processing_options)
  rescue ActiveStorage::IntegrityError => e
    Rails.logger.warn "Variant generation failed: #{e.message}"
    fallback_image
  end
end
```

#### **4. 画像最適化パターン**
```ruby
# 用途別variant定義
def thumbnail
  image.variant(resize_to_fill: [150, 150])
end

def medium
  image.variant(resize_to_limit: [800, 600], quality: 85)
end

def large
  image.variant(resize_to_limit: [1200, 900], quality: 90)
end
```

### 🎁 **再利用可能コンポーネント**
- **画像バリデーション**: 形式・サイズ制限の共通設定
- **エラーハンドリング**: IntegrityError対応の汎用パターン
- **Variant生成**: 用途別画像サイズの標準化
- **フォールバック表示**: 画像なし時の統一UI

---

**Active Storage + 画像処理システムは、お供だちアプリの安定性と品質を支える
重要な技術基盤として、確実にファイルアップロード機能を提供しています。**