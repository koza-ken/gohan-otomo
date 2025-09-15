# 🚀 主要機能の技術実装解説

このドキュメントでは、お供だちアプリの主要機能について、開発時の重要な技術判断や実装パターンを解説します。

## 🎯 システム全体の設計思想

### ハイブリッド画像システム
**3段階フォールバック設計による堅牢な画像表示**

```ruby
# 優先順位:
# 1. ユーザーアップロード画像（Active Storage）
# 2. 外部URL画像（楽天API取得）
# 3. プレースホルダー画像（🍚アイコン）

def display_image(size = :medium)
  return thumbnail_image if size == :thumbnail && image.attached?
  return medium_image if size == :medium && image.attached?
  image_url.presence  # 外部URLにフォールバック
end
```

**学習ポイント**:
- ユーザビリティと拡張性の両立
- Active Storage variantによる効率的な画像最適化
- graceful degradationによるエラー耐性

### Service Object パターンによる責任分離

**ファットコントローラー解消（166行→2行）**

```ruby
# Before: ファットコントローラー
class Api::Rakuten::ProductsController
  def search_products
    # バリデーション、ビジネスロジック、レスポンス生成が混在（166行）
  end
end

# After: Service Object + Result Object
class Api::Rakuten::ProductsController
  def search_products
    result = RakutenSearchService.new(params[:title], current_user).call
    render json: result.to_json_response, status: result.http_status
  end
end

# app/services/rakuten_search_service.rb
class RakutenSearchService
  def initialize(input, user)
    @input = input.to_s.strip
    @user = user
  end

  def call
    return invalid_input_result if @input.blank?

    products = if rakuten_url?
      fetch_from_url
    else
      fetch_from_search
    end

    SearchResult.new(products: products, success: true)
  rescue => e
    error_result(e.message)
  end
end
```

**学習ポイント**:
- 単一責任原則の実践
- テストしやすい設計
- エラーハンドリングの統一

## 🔥 パフォーマンス最適化

### N+1問題の根本解決

**SQLクエリ64%削減の実現**

```ruby
# Before: N+1問題（11回のクエリ）
@posts = Post.page(params[:page]).per(8)
# posts.each { |post| post.likes.count }  # 8回の個別クエリ
# posts.each { |post| post.user.name }    # 8回の個別クエリ
# posts.each { |post| post.comments.count } # 8回の個別クエリ

# After: includes による一括取得（4回のクエリ）
@posts = Post.includes(:user, :comments, :likes)
             .page(params[:page]).per(8)
```

**測定結果**:
- クエリ数: 11回 → 4回（64%削減）
- ページ表示速度の大幅向上

### 楽天API統合でのCORS解決

**プロキシパターンによるCORS回避**

```ruby
# app/controllers/api/rakuten/products_controller.rb
def proxy_image
  # セキュリティ: 楽天ドメインのみ許可
  unless image_url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
    render json: { error: '許可されていない画像URLです' }, status: :forbidden
    return
  end

  # リファラー設定でCORS回避
  request['Referer'] = 'https://www.rakuten.co.jp/'
  response = http.request(request)
  send_data response.body, type: response.content_type
end
```

**学習ポイント**:
- ブラウザCORS制限の理解
- サーバーサイドプロキシの活用
- セキュリティを考慮したドメイン制限

## 💡 UX設計の重要判断

### LocalStorage活用による初回判定

**サーバーレス状態管理**

```javascript
// app/javascript/controllers/welcome_modal_controller.js
export default class extends Controller {
  connect() {
    const hasVisited = localStorage.getItem('has_visited_otomo')
    const isTopPage = ['/', '/posts'].includes(window.location.pathname)

    if (!hasVisited && isTopPage) {
      setTimeout(() => this.showModal(), 500)
    }
  }

  closeModal() {
    localStorage.setItem('has_visited_otomo', 'true')
    this.hideModal()
  }
}
```

**メリット**:
- サーバー負荷軽減
- プライバシー配慮（ローカル保存のみ）
- 高速な判定処理

### Turbo Stream によるリアルタイム更新

**いいね機能・コメント機能のAjax実装**

```erb
<!-- create.turbo_stream.erb -->
<%= turbo_stream.replace "like_button_#{@post.id}" do %>
  <%= render 'likes/button', post: @post %>
<% end %>

<%= turbo_stream.replace "comments_list" do %>
  <%= render partial: 'comments/comment', collection: @post.comments.order(created_at: :desc) %>
<% end %>
```

**学習ポイント**:
- `prepend` vs `replace` の使い分け
- 条件分岐表示との相性問題
- Turbo Streamの部分更新設計

## 🛡️ セキュリティ対策

### SSRF攻撃完全防止

**外部URL制限の多層防御**

```ruby
# 1. モデルバリデーション
validates :image_url, format: {
  with: %r{\Ahttps://thumbnail\.image\.rakuten\.co\.jp/.*\z},
  message: '楽天の画像URLのみ許可されています'
}, allow_blank: true

# 2. フロントエンド制限
<%= form.url_field :image_url, readonly: true %>

# 3. コントローラー検証
def validate_rakuten_domain(url)
  return false unless url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
  true
end
```

### Rails 7対応のセキュリティ実装

**Turbo対応の確認ダイアログ**

```erb
<!-- Rails 6まで -->
<%= link_to "削除", post_path(@post),
    data: { confirm: "本当に削除しますか？", method: :delete } %>

<!-- Rails 7 + Turbo -->
<%= link_to "削除", post_path(@post),
    data: { turbo_confirm: "本当に削除しますか？", turbo_method: :delete } %>
```

## 📱 レスポンシブ設計の実践

### 段階的簡略化による最適解

**Level 3最大簡略化の成功事例**

```erb
<!-- Level 1: 複雑な検索フォーム -->
<div class="p-6 space-y-4">
  <div>検索ワード + ソート機能</div>
</div>

<!-- Level 3: 最大簡略化（画面占有率70%削減）-->
<div class="p-2">
  <%= form_with class: "flex space-x-2" do |form| %>
    <%= form.text_field :search, class: "flex-1" %>
    <%= form.submit "検索" %>
  <% end %>
</div>
```

### Flexbox による統一レイアウト

**カード高さ統一 + 統計情報下端固定**

```css
.card {
  @apply flex flex-col h-full;
}

.card-content {
  @apply flex-1 flex flex-col;
}

.card-stats {
  @apply mt-auto;  /* 下端固定 */
}
```

## 🧪 テスト戦略

### Rails 7準拠のテスト設計

**Request Spec中心のテスト構成**

- **Model Spec**: バリデーション・アソシエーション（115テスト）
- **Request Spec**: HTTP処理・認証（143テスト）
- **System Spec**: JavaScript統合・ブラウザ操作（58テスト）

**重要な注意点**:
```ruby
# ⚠️ 危険: HTTPメソッドと同名変数は禁止
let(:post) { ... }    # HTTPメソッドpostと競合

# ✅ 安全: 異なる変数名を使用
let(:post_record) { ... }
```

### Active Storage テストパターン

```ruby
# FactoryBot（軽量）
trait :with_attached_image do
  after(:build) do |post|
    post.image.attach(
      io: StringIO.new("fake image data"),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end
end

# Model Spec（実ファイル）
it "画像を添付できる" do
  file = fixture_file_upload('test_image.jpg', 'image/jpeg')
  post.image.attach(file)
  expect(post.image.attached?).to be true
end
```

## 🎓 重要な学習ポイント

### 1. 段階的リファクタリングの価値
- 小さな改善の積み重ね
- 既存機能への影響ゼロでの改善
- デッドコード削除による整理

### 2. Rails標準パターンの重要性
- STI廃止 → シンプルなhas_many関連
- Active Storage採用（Rails標準）
- Service Object による責任分離

### 3. ユーザビリティ重視の設計
- graceful degradation
- レスポンシブファーストのアプローチ
- エラー時の適切なフォールバック

### 4. パフォーマンス最適化の実践
- N+1問題の早期発見・解決
- includes による効率的なデータ取得
- LocalStorage活用によるサーバー負荷軽減

これらの実装パターンは、Rails 7アプリケーション開発における実践的なベストプラクティスとして活用できます。