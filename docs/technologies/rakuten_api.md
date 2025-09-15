# 🛒 楽天API連携 - 完全復習ガイド

## 概要

**楽天ウェブサービスAPI** を使用した商品検索・画像取得機能。
ユーザーが商品名や楽天市場URLを入力すると、自動で商品情報と画像を取得して投稿に活用できます。

### API の基本情報
- **提供元**: 楽天株式会社
- **API名**: 楽天ウェブサービス - 楽天市場商品検索API
- **認証方式**: Application ID による認証
- **料金**: 無料（リクエスト制限あり）

## このアプリでの役割

### 🎯 **主な機能**
1. **商品名検索**: キーワードから楽天市場の商品を検索
2. **URL検索**: 楽天市場の商品URLから直接商品情報を取得
3. **画像自動取得**: 商品画像の自動設定
4. **通販リンク設定**: 楽天市場への購入リンク自動設定

### 💡 **なぜ必要だったのか**
- **ユーザビリティ向上**: 手動画像アップロードの手間削減
- **投稿品質向上**: 統一感のある商品画像の提供
- **購買促進**: 通販リンクによる購入導線の確保
- **データ品質**: 正確な商品名・情報の取得

## 実装内容

### 🔧 **1. Service Object実装**

#### RakutenProductService（商品情報取得）
```ruby
# app/services/rakuten_product_service.rb
class RakutenProductService
  RAKUTEN_APPLICATION_ID = Rails.application.credentials.dig(:rakuten, :application_id)

  # 商品名検索
  def self.fetch_product_candidates(title, limit: 12)
    return [] if title.blank?

    client = RakutenWebService::Ichiba::Item
    items = client.search(keyword: title, hits: limit)

    items.map { |item| format_product_info(item) }
  rescue => e
    Rails.logger.error "楽天API商品検索エラー: #{e.message}"
    []
  end

  # URL検索（3段階フォールバック）
  def self.fetch_product_from_url(rakuten_url)
    return [] if rakuten_url.blank?

    shop_name, item_code = extract_shop_and_item_code(rakuten_url)
    return [] unless shop_name && item_code

    # 1. 正確検索
    result = search_by_item_code(shop_name, item_code)
    return result if result.any?

    # 2. 部分検索
    result = search_by_partial_item_code(item_code)
    return result if result.any?

    # 3. ショップ内検索
    search_by_shop_name(shop_name)
  end

  private

  def self.format_product_info(item)
    {
      title: strip_html(item.item_name),
      image_url: get_first_image_url(item),
      rakuten_url: item.item_url,
      price: item.item_price
    }
  end

  def self.get_first_image_url(item)
    if item.medium_image_urls&.any?
      image_url = item.medium_image_urls.first
      # URLパラメータを400x400に変換
      image_url.gsub(/\?_ex=\d+x\d+/, '?_ex=400x400')
    elsif item.small_image_urls&.any?
      item.small_image_urls.first
    end
  end

  def self.extract_shop_and_item_code(url)
    patterns = [
      %r{https?://(?:www\.)?item\.rakuten\.co\.jp/([^/]+)/([^/?]+)},
      %r{https?://(?:www\.)?rakuten\.co\.jp/([^/]+)/cabinet/([^/?]+)\.html}
    ]

    patterns.each do |pattern|
      match = url.match(pattern)
      return [match[1], match[2]] if match
    end

    [nil, nil]
  end
end
```

#### RakutenSearchService（統合検索サービス）
```ruby
# app/services/rakuten_search_service.rb
class RakutenSearchService
  def initialize(input, user)
    @input = input.to_s.strip
    @user = user
  end

  def call
    return invalid_input_result if @input.blank?

    products = if rakuten_url?
      RakutenProductService.fetch_product_from_url(@input)
    else
      RakutenProductService.fetch_product_candidates(@input, limit: 12)
    end

    SearchResult.new(products: products, success: true)
  rescue => e
    Rails.logger.error "楽天検索サービスエラー: #{e.message}"
    error_result(e.message)
  end

  private

  def rakuten_url?
    @input.match?(%r{https?://(?:www\.|item\.)?rakuten\.co\.jp/})
  end

  def invalid_input_result
    SearchResult.new(products: [], success: false, error: "検索キーワードを入力してください")
  end

  def error_result(message)
    SearchResult.new(products: [], success: false, error: message)
  end
end
```

### 🎮 **2. Controller実装（Service Object パターン）**

```ruby
# app/controllers/api/rakuten/products_controller.rb
class Api::Rakuten::ProductsController < ApplicationController
  before_action :authenticate_user!

  def search_products
    result = RakutenSearchService.new(params[:title], current_user).call
    render json: result.to_json_response, status: result.http_status
  end

  # CORSエラー解決のためのプロキシエンドポイント
  def proxy_image
    image_url = params[:image_url]

    # セキュリティ: 楽天ドメインのみ許可
    unless image_url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
      render json: { error: '許可されていない画像URLです' }, status: :forbidden
      return
    end

    uri = URI(image_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Referer'] = 'https://www.rakuten.co.jp/'
    request['User-Agent'] = 'Mozilla/5.0 (compatible; RakutenImageProxy/1.0)'

    response = http.request(request)
    send_data response.body, type: response.content_type || 'image/jpeg'
  rescue => e
    Rails.logger.error "楽天画像プロキシエラー: #{e.message}"
    head :not_found
  end
end
```

### 🌐 **3. フロントエンド実装（Stimulus）**

```javascript
// app/javascript/controllers/product_search_controller.js
export default class extends Controller {
  static targets = ["title", "candidatesDesktop", "candidatesMobile"]

  async searchByProductName() {
    const title = this.titleTarget.value.trim()
    if (!title) return

    await this.searchProducts(title)
  }

  async searchByUrl() {
    const urlField = document.getElementById('rakuten_url')
    const rakutenUrl = urlField.value.trim()
    if (!rakutenUrl) return

    // 一時的プレースホルダー表示
    this.titleTarget.value = '楽天URL検索中...'

    try {
      await this.searchProducts(rakutenUrl)
    } catch (error) {
      // エラー時は元のURLに復元
      urlField.value = rakutenUrl
      this.titleTarget.value = ''
      console.error('楽天URL検索エラー:', error)
    }
  }

  async searchProducts(query) {
    try {
      const response = await fetch('/api/rakuten/search_products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: query })
      })

      const data = await response.json()

      if (data.success) {
        this.displayCandidates(data.products)
      } else {
        console.error('楽天API検索失敗:', data.error)
      }
    } catch (error) {
      console.error('楽天API通信エラー:', error)
    }
  }

  selectProduct(event) {
    const button = event.currentTarget
    const title = button.dataset.title
    const imageUrl = button.dataset.imageUrl
    const rakutenUrl = button.dataset.rakutenUrl

    // 投稿フォームに自動入力
    this.titleTarget.value = title

    // 画像URL設定（プロキシ経由）
    const imageUrlField = document.getElementById('post_image_url')
    if (imageUrlField && imageUrl) {
      imageUrlField.value = imageUrl
      // 画像プレビュー更新をトリガー
      imageUrlField.dispatchEvent(new Event('input'))
    }

    // 通販リンク設定
    const linkField = document.getElementById('post_link')
    if (linkField && rakutenUrl) {
      linkField.value = rakutenUrl
    }

    this.clearCandidates()
  }
}
```

## 学習ポイント

### 🎯 **1. CORS問題の根本的解決**

#### 問題
```javascript
// ❌ 直接楽天画像URLにアクセス → CORSエラー
fetch('https://thumbnail.image.rakuten.co.jp/...')
```

#### 解決（プロキシパターン）
```ruby
# ✅ Rails側でプロキシサーバーを実装
def proxy_image
  # サーバーサイドで楽天APIにアクセス（CORS制限なし）
  request['Referer'] = 'https://www.rakuten.co.jp/'
  response = http.request(request)
  send_data response.body, type: response.content_type
end
```

**学習ポイント**:
- ブラウザのCORS制限はサーバー間通信には適用されない
- 適切なリファラー設定で外部サービスの制限を回避
- セキュリティを考慮したドメイン制限の実装

### 🔄 **2. 3段階フォールバック検索**

```ruby
def self.fetch_product_from_url(rakuten_url)
  # 1. 正確検索（shop_name + item_code完全一致）
  result = search_by_item_code(shop_name, item_code)
  return result if result.any?

  # 2. 部分検索（item_codeの部分一致）
  result = search_by_partial_item_code(item_code)
  return result if result.any?

  # 3. ショップ内検索（shop_nameでの一般検索）
  search_by_shop_name(shop_name)
end
```

**学習ポイント**:
- URLから商品を確実に見つけるためのフォールバック設計
- API制限を考慮した効率的な検索順序
- ユーザビリティ重視の実装方針

### 🔐 **3. セキュリティ対策（SSRF攻撃防止）**

```ruby
# 多層防御の実装
# 1. モデルバリデーション
validates :image_url, format: {
  with: %r{\Ahttps://thumbnail\.image\.rakuten\.co\.jp/.*\z},
  message: '楽天の画像URLのみ許可されています'
}

# 2. コントローラー検証
unless image_url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
  render json: { error: '許可されていない画像URLです' }, status: :forbidden
end

# 3. フロントエンド制限
<%= form.url_field :image_url, readonly: true %>
```

### ⚡ **4. Service Object パターンの実践**

**Controller**: 2行のシンプル実装
```ruby
def search_products
  result = RakutenSearchService.new(params[:title], current_user).call
  render json: result.to_json_response, status: result.http_status
end
```

**Service**: 複雑なビジネスロジック
```ruby
class RakutenSearchService
  def call
    # URL判定・検索実行・エラーハンドリング
  end
end
```

**学習ポイント**:
- 単一責任原則の実践
- テストしやすい設計
- エラーハンドリングの統一

## 関連ファイル

### 🔧 **バックエンド**
```
app/services/
├── rakuten_product_service.rb      # 楽天API基本機能
└── rakuten_search_service.rb       # 統合検索サービス

app/controllers/api/rakuten/
└── products_controller.rb          # API エンドポイント

spec/services/
└── rakuten_product_service_spec.rb # Service テスト（15例）
```

### 🎨 **フロントエンド**
```
app/javascript/controllers/
└── product_search_controller.js    # 商品検索制御

app/views/posts/
├── _form.html.erb                  # 投稿フォーム統合
└── _rakuten_search.html.erb        # 商品候補表示
```

### ⚙️ **設定ファイル**
```
config/
├── credentials.yml.enc             # 楽天Application ID
└── routes.rb                       # APIルート定義

Gemfile
└── rakuten_web_service            # 楽天APIクライアントgem
```

## 他プロジェクトでの応用

### 🔄 **汎用的なパターン**

#### **1. 外部API連携パターン**
```ruby
class ExternalApiService
  def self.fetch_data(params)
    # API呼び出し
    # エラーハンドリング
    # データ変換
  rescue => e
    Rails.logger.error "API呼び出しエラー: #{e.message}"
    []
  end
end
```

#### **2. プロキシサーバーパターン**
```ruby
def proxy_external_resource
  # セキュリティチェック
  # 外部リソース取得
  # レスポンス転送
end
```

#### **3. フォールバック検索パターン**
```ruby
def search_with_fallback(query)
  # 1. 正確検索
  result = exact_search(query)
  return result if result.any?

  # 2. 部分検索
  result = partial_search(query)
  return result if result.any?

  # 3. 関連検索
  related_search(query)
end
```

### 🎁 **再利用可能コンポーネント**
- **API クライアント**: 他の外部API連携でも活用
- **プロキシ機能**: CORS問題の汎用的解決策
- **検索UI**: 商品以外の検索機能でも応用可能
- **エラーハンドリング**: API連携の標準的なパターン

---

**楽天API連携は、お供だちアプリのコア機能として、
ユーザビリティとデータ品質の両面で大きな価値を提供している重要な技術実装です。**