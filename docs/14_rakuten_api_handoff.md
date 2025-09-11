# 🛒 14_rakuten_api_#41 実装引継ぎ資料

## 📅 プロジェクト状況
- **前回完了**: 13_add_image_#40（WebP画像最適化機能）
- **次期実装**: 14_rakuten_api_#41（楽天商品検索API統合機能）
- **実装準備**: 完了（詳細設計・タスク分解済み）
- **学習方式**: Learning Mode（段階的実装・選択肢比較）

## 🎯 実装目標

### **機能概要**
楽天商品検索APIを活用して、外部商品画像の自動取得とOGP画像最適化を実現

### **ユーザー体験**
```
ユーザー: 楽天商品URLを入力
     ↓
アプリ: 商品情報を自動取得
     ↓  
投稿: 画像・タイトル・説明が自動設定
     ↓
X投稿: 美しいカード表示
```

### **技術的価値**
- 外部API連携の基本パターン習得
- 非同期処理とユーザー体験の両立
- OGP・SNS最適化の実装手法
- エラーハンドリングとレジリエント設計

## 📋 実装タスク詳細

### **🔧 Task 1: 楽天API基盤実装**

#### **1-1. 事前準備**
```
□ Rakuten Developers登録
  URL: https://webservice.rakuten.co.jp/
  - アカウント作成
  - 新しいアプリ登録
  - アプリケーションID取得

□ 認証情報設定
  - Rails credentials編集
  - 環境変数設定
```

#### **1-2. Gem導入**
```ruby
# Gemfile
gem 'rakuten_web_service'

# config/initializers/rakuten.rb  
RakutenWebService.configure do |c|
  c.application_id = Rails.application.credentials.rakuten[:application_id]
  c.affiliate_id = Rails.application.credentials.rakuten[:affiliate_id] # 任意
end
```

#### **1-3. 基本サービスクラス**
```ruby
# app/services/rakuten_product_service.rb
class RakutenProductService
  def self.search_by_keyword(keyword)
    RakutenWebService::Ichiba::Item.search(keyword: keyword)
  rescue => e
    Rails.logger.error "楽天API検索エラー: #{e.message}"
    []
  end
  
  def self.get_item_by_url(rakuten_url)
    item_code, shop_code = extract_codes_from_url(rakuten_url)
    return nil unless item_code && shop_code
    
    search_item(item_code, shop_code)
  end
  
  private
  
  def self.extract_codes_from_url(url)
    # URL解析実装
    # パターン例:
    # https://item.rakuten.co.jp/shop-name/item-code/
    # https://www.rakuten.co.jp/shop-name/cabinet/item-code.html
  end
  
  def self.search_item(item_code, shop_code)
    # API検索実装
  end
end
```

### **🔧 Task 2: 楽天URL解析・商品情報取得**

#### **2-1. URL解析パターン実装**
```ruby
def self.extract_codes_from_url(url)
  patterns = [
    # パターン1: item.rakuten.co.jp/shop/item/
    %r{item\.rakuten\.co\.jp/([^/]+)/([^/?]+)},
    # パターン2: www.rakuten.co.jp/shop/cabinet/item.html
    %r{www\.rakuten\.co\.jp/([^/]+)/cabinet/([^/?]+)\.html}
  ]
  
  patterns.each do |pattern|
    match = url.match(pattern)
    return [match[2], match[1]] if match # [item_code, shop_code]
  end
  
  nil
end
```

#### **2-2. 商品情報構造化**
```ruby
def self.format_product_info(rakuten_item)
  {
    title: rakuten_item.name,                    # ✅ 修正: item_name → name
    description: strip_html(rakuten_item.caption), # ✅ 修正: item_caption → caption  
    image_url: get_first_image_url(rakuten_item), # ✅ 修正: medium_image_url → 配列処理
    price: rakuten_item.price,                   # ✅ 修正: item_price → price
    rakuten_url: rakuten_item.url,              # ✅ 修正: item_url → url
    shop_name: rakuten_item.shop_name           # ✅ 変更なし
  }
end

private

def self.get_first_image_url(item)
  return nil unless item.medium_image_urls&.any?
  item.medium_image_urls.first["imageUrl"]
end

def self.strip_html(html)
  html&.gsub(/<\/?[^>]*>/, '')&.strip
end
```

### **🔧 Task 3: 投稿フォーム統合**

#### **3-1. フォーム拡張**
```erb
<!-- app/views/posts/_form.html.erb に追加 -->
<div class="mb-6 border border-red-200 rounded-lg p-4 bg-red-50">
  <h3 class="text-lg font-medium text-red-600 mb-3 flex items-center">
    🛒 楽天商品から投稿作成（任意）
  </h3>
  
  <%= form.label :rakuten_url, "楽天商品URL", 
      class: "block text-sm font-medium text-red-700 mb-2" %>
  <%= form.url_field :rakuten_url,
      placeholder: "https://item.rakuten.co.jp/shop/item/",
      class: "w-full px-3 py-2 border border-red-200 rounded-lg focus:ring-red-400",
      data: { 
        controller: "rakuten-fetch",
        action: "blur->rakuten-fetch#fetchProduct"
      } %>
      
  <div class="mt-3 flex gap-2">
    <button type="button" 
            data-action="click->rakuten-fetch#fetchProduct"
            class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition">
      📦 商品情報を取得
    </button>
    <button type="button"
            data-action="click->rakuten-fetch#clearProduct" 
            class="bg-gray-400 hover:bg-gray-500 text-white px-4 py-2 rounded-lg text-sm font-medium transition">
      🗑️ クリア
    </button>
  </div>
  
  <!-- 商品情報プレビューエリア -->
  <div data-rakuten-fetch-target="preview" class="mt-4 hidden border border-red-300 rounded-lg p-3 bg-white">
    <h4 class="font-medium text-red-600 mb-2">📦 取得した商品情報</h4>
    <div data-rakuten-fetch-target="previewContent">
      <!-- 商品情報が動的に表示される -->
    </div>
    <div class="mt-3 text-sm text-red-600">
      ✅ この情報が投稿フォームに自動入力されます
    </div>
  </div>
</div>
```

#### **3-2. Stimulus実装**
```javascript
// app/javascript/controllers/rakuten_fetch_controller.js
export default class extends Controller {
  static targets = ["preview", "previewContent"]
  
  connect() {
    console.log("楽天商品取得コントローラー初期化")
  }
  
  async fetchProduct(event) {
    const urlField = event.target.closest('form').querySelector('input[name*="rakuten_url"]')
    const url = urlField?.value?.trim()
    
    if (!url) {
      this.showError("楽天商品URLを入力してください")
      return
    }
    
    if (!this.isValidRakutenUrl(url)) {
      this.showError("有効な楽天商品URLを入力してください")
      return
    }
    
    this.showLoading()
    
    try {
      const response = await fetch('/api/rakuten/fetch_product', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ rakuten_url: url })
      })
      
      const result = await response.json()
      
      if (response.ok && result.success) {
        this.updateFormFields(result.product)
        this.showPreview(result.product)
      } else {
        this.showError(result.error || "商品情報の取得に失敗しました")
      }
    } catch (error) {
      console.error('楽天API エラー:', error)
      this.showError("ネットワークエラーが発生しました")
    }
  }
  
  isValidRakutenUrl(url) {
    return /^https?:\/\/(item|www)\.rakuten\.co\.jp\//.test(url)
  }
  
  updateFormFields(product) {
    const form = this.element.closest('form')
    if (!form) return
    
    // タイトル自動入力
    const titleField = form.querySelector('input[name*="title"]')
    if (titleField && !titleField.value.trim()) {
      titleField.value = product.title
    }
    
    // 説明文自動入力
    const descField = form.querySelector('textarea[name*="description"]')
    if (descField && !descField.value.trim()) {
      descField.value = `${product.description}\n\n💰 楽天価格: ${product.price}円`
    }
    
    // 画像URL自動入力
    const imageUrlField = form.querySelector('input[name*="image_url"]')
    if (imageUrlField && !imageUrlField.value.trim()) {
      imageUrlField.value = product.image_url
    }
    
    // 通販リンク自動入力
    const linkField = form.querySelector('input[name*="link"]')
    if (linkField && !linkField.value.trim()) {
      linkField.value = product.rakuten_url
    }
  }
  
  showPreview(product) {
    const previewHtml = `
      <div class="flex gap-3">
        <img src="${product.image_url}" alt="${product.title}" 
             class="w-16 h-16 object-cover rounded border">
        <div class="flex-1">
          <h5 class="font-medium text-gray-800 text-sm">${product.title}</h5>
          <p class="text-red-600 font-medium text-sm">💰 ${product.price}円</p>
          <p class="text-gray-600 text-xs mt-1">${product.shop_name}</p>
        </div>
      </div>
    `
    
    this.previewContentTarget.innerHTML = previewHtml
    this.previewTarget.classList.remove('hidden')
  }
  
  showLoading() {
    this.previewContentTarget.innerHTML = `
      <div class="text-center py-4">
        <div class="animate-spin inline-block w-6 h-6 border-2 border-red-500 border-t-transparent rounded-full"></div>
        <p class="mt-2 text-sm text-red-600">商品情報を取得中...</p>
      </div>
    `
    this.previewTarget.classList.remove('hidden')
  }
  
  showError(message) {
    this.previewContentTarget.innerHTML = `
      <div class="text-center py-4 text-red-600">
        <p class="text-sm">⚠️ ${message}</p>
      </div>
    `
    this.previewTarget.classList.remove('hidden')
  }
  
  clearProduct() {
    this.previewTarget.classList.add('hidden')
    // フォームフィールドもクリアする場合はここに実装
  }
}
```

### **🔧 Task 4: OGP画像最適化機能**

#### **4-1. OGP専用variant追加**
```ruby
# app/models/post.rb に追加
def ogp_image
  return nil unless image.attached?
  
  # 1200×630px、JPEG強制（SNS互換性）
  image.variant(
    resize_to_fill: [1200, 630], 
    quality: 85, 
    format: :jpg
  )
end

def twitter_card_image
  return nil unless has_image?
  
  # Twitter Card用最適化
  if image.attached?
    ogp_image
  else
    # 外部URL画像の場合はそのまま使用
    image_url
  end
end
```

#### **4-2. メタタグ動的生成改善**
```erb
<!-- app/views/posts/show.html.erb のメタタグ更新 -->
<% content_for :title, @post.title %>
<% content_for :og_title, "「#{@post.title}」- お供だち" %>
<% content_for :og_type, "article" %>
<% content_for :og_url, request.original_url %>
<% content_for :og_description, truncate(@post.description, length: 100) %>

<!-- OGP画像の優先順位 -->
<% if @post.image.attached? %>
  <% content_for :og_image, url_for(@post.ogp_image) %>
  <% content_for :twitter_card, "summary_large_image" %>
<% elsif @post.image_url.present? %>
  <% content_for :og_image, @post.image_url %>
  <% content_for :twitter_card, "summary_large_image" %>
<% else %>
  <% content_for :twitter_card, "summary" %>
<% end %>
```

### **🔧 Task 5: APIエンドポイント実装**

#### **5-1. ルーティング追加**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # 既存ルート...
  
  namespace :api do
    namespace :rakuten do
      post 'fetch_product', to: 'products#fetch_product'
    end
  end
end
```

#### **5-2. APIコントローラー**
```ruby
# app/controllers/api/rakuten/products_controller.rb
class Api::Rakuten::ProductsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :null_session
  
  def fetch_product
    rakuten_url = params[:rakuten_url]
    
    if rakuten_url.blank?
      render json: { success: false, error: 'URLが指定されていません' }, status: 400
      return
    end
    
    begin
      product_info = RakutenProductService.get_item_by_url(rakuten_url)
      
      if product_info
        render json: { 
          success: true, 
          product: product_info 
        }
      else
        render json: { 
          success: false, 
          error: '商品情報が見つかりませんでした。URLを確認してください。' 
        }, status: 404
      end
    rescue => e
      Rails.logger.error "楽天API取得エラー: #{e.message}"
      render json: { 
        success: false, 
        error: 'サーバーエラーが発生しました。時間をおいて再試行してください。' 
      }, status: 500
    end
  end
end
```

## 🧪 テスト実装方針

### **Model Spec**
```ruby
# spec/services/rakuten_product_service_spec.rb
RSpec.describe RakutenProductService do
  describe '.get_item_by_url' do
    context '有効な楽天URLの場合' do
      it '商品情報を取得できる' do
        # テスト実装
      end
    end
    
    context '無効なURLの場合' do
      it 'nilを返す' do
        # テスト実装  
      end
    end
  end
end
```

### **Request Spec**
```ruby
# spec/requests/api/rakuten/products_spec.rb
RSpec.describe 'Api::Rakuten::Products', type: :request do
  let(:user) { create(:user) }
  
  before { sign_in user }
  
  describe 'POST /api/rakuten/fetch_product' do
    context '有効な楽天URLの場合' do
      it '商品情報を返す' do
        # テスト実装
      end
    end
  end
end
```

### **System Spec**
```ruby
# spec/system/rakuten_integration_spec.rb
RSpec.describe '楽天API統合', type: :system do
  let(:user) { create(:user) }
  
  before do
    sign_in user
    visit new_post_path
  end
  
  it '楽天URLから商品情報を取得して投稿作成できる' do
    # テスト実装
  end
end
```

## ⚠️ 実装時の注意点

### **技術的制約**
- 楽天APIレート制限: 1日100万リクエスト（通常十分）
- レスポンス時間: 平均1-3秒（UI考慮）
- エラーハンドリング: 必須（ネットワーク・API障害対応）

### **ユーザー体験**
- ローディング表示必須
- エラーメッセージの分かりやすさ
- 手動編集との併用機能
- モバイル対応

### **セキュリティ**
- CSRF対策
- 入力値検証
- APIキー漏洩防止
- レート制限対応

## 🎯 成功基準

### **機能要件**
- ✅ 楽天商品URLから商品情報を自動取得
- ✅ 商品画像が投稿に自動設定
- ✅ OGP画像が正しく生成
- ✅ X投稿で美しいカード表示

### **品質要件**
- ✅ 全テスト成功
- ✅ エラーハンドリング完備
- ✅ モバイル対応
- ✅ パフォーマンス問題なし

### **学習価値**
- ✅ 外部API連携パターン習得
- ✅ 非同期処理実装経験
- ✅ OGP最適化知識
- ✅ エラーハンドリング設計

## 🔧 実装中の重要な修正（2025年9月11日）

### **楽天API メソッド名の正しい命名**

**動作確認により判明した正しいメソッド名**：
```ruby
# ❌ 引継ぎ資料の想定（間違い）
item.item_name        # 存在しない
item.item_price       # 存在しない  
item.item_caption     # 存在しない
item.medium_image_url # 存在しない
item.item_url         # 存在しない

# ✅ 実際のメソッド名（Rails console で確認済み）
item.name             # 商品名
item.price            # 価格
item.caption          # 商品説明（HTML含む）
item.medium_image_urls # 画像URL配列 [{"imageUrl" => "https://..."}]
item.url              # 商品URL
item.shop_name        # ショップ名（変更なし）
```

**画像URL取得の正しい方法**：
```ruby
# medium_image_urls は配列で、各要素がハッシュ
def get_first_image_url(item)
  return nil unless item.medium_image_urls&.any?
  item.medium_image_urls.first["imageUrl"]
end
```

**実装修正状況**：
- ✅ docs/14_rakuten_api_handoff.md のコード例を修正
- ✅ format_product_info メソッドの修正完了
- ✅ Rails console での動作確認済み

## 📚 参考資料

### **楽天API**
- [楽天商品検索API](https://webservice.rakuten.co.jp/documentation/ichiba-item-search)
- [rakuten_web_service gem](https://github.com/rakuten-ws/rws-ruby-sdk)

### **技術実装**
- Rails 7.2 外部API連携ベストプラクティス
- Stimulus コントローラー実装パターン
- Active Storage OGP画像最適化

---

**🎯 次回開発時は、Task 1から段階的に実装を開始してください！**
*Learning Mode による選択肢比較・理由説明を重視した実装アプローチを推奨します。*