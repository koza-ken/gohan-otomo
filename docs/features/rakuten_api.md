# 🛒 楽天API連携機能

## 概要

楽天市場APIを使用した商品検索・画像取得機能の実装ドキュメント。
商品名検索・楽天URL検索の両方に対応し、CORSエラーをプロキシパターンで解決。

## 主要機能

### ✅ 実装済み機能
- **商品名検索**: キーワードによる楽天商品検索
- **楽天URL検索**: 楽天市場URLからの直接商品取得
- **画像自動取得**: 商品画像の自動設定
- **プロキシサーバー**: CORSエラー完全解決
- **セキュリティ対策**: SSRF攻撃防止

## 技術実装

### Service Object パターン
```ruby
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

  private

  def rakuten_url?
    @input.match?(%r{https?://(?:www\.|item\.)?rakuten\.co\.jp/})
  end

  def fetch_from_url
    # URL解析・3段階フォールバック検索
    RakutenProductService.fetch_product_from_url(@input)
  end

  def fetch_from_search
    # 商品名検索
    RakutenProductService.fetch_product_candidates(@input, limit: 12)
  end
end
```

### プロキシパターンでCORS解決
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
  request['User-Agent'] = 'Mozilla/5.0 (compatible; RakutenImageProxy/1.0)'

  response = http.request(request)
  send_data response.body, type: response.content_type || 'image/jpeg'
end
```

### フロントエンド統合（Stimulus）
```javascript
// app/javascript/controllers/product_search_controller.js
export default class extends Controller {
  static targets = ["title", "candidatesDesktop", "candidatesMobile"]

  async searchProducts() {
    const title = this.titleTarget.value.trim()
    if (!title) return

    // URL判定による処理分岐
    const isRakutenUrl = title.match(/https?:\/\/(?:www\.|item\.)?rakuten\.co\.jp\//)

    try {
      if (isRakutenUrl) {
        // URL検索時の一時的プレースホルダー
        this.titleTarget.value = '楽天URL検索中...'
      }

      const response = await fetch('/api/rakuten/search_products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title })
      })

      const data = await response.json()
      this.displayCandidates(data.products)

    } catch (error) {
      // エラー時の復元処理
      if (isRakutenUrl) {
        this.titleTarget.value = title
      }
      console.error('楽天API検索エラー:', error)
    }
  }
}
```

## セキュリティ対策

### SSRF攻撃防止
```ruby
# 多層防御の実装
# 1. モデルバリデーション
validates :image_url, format: {
  with: %r{\Ahttps://thumbnail\.image\.rakuten\.co\.jp/.*\z},
  message: '楽天の画像URLのみ許可されています'
}, allow_blank: true

# 2. フロントエンド制限
<%= form.url_field :image_url, readonly: true %>

# 3. コントローラー検証
def validate_rakuten_domain(url)
  url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
end
```

## UX改善

### 統合検索体験
- **プレースホルダー**: 「商品名または楽天市場のURLを入力」
- **動的バリデーション**: URL(1000文字) vs 商品名(100文字)
- **自動判定**: URL形式の自動識別
- **エラーハンドリング**: 検索失敗時の適切な復元

### レスポンシブ対応
- **モバイル**: 商品名直下に自然な検索フロー
- **PC**: 右側拡大エリアで3-4列グリッド表示
- **共通**: 12件表示・スクロール対応

## 学習ポイント

### 1. CORS問題の根本的解決
- ブラウザCORS制限はサーバー間通信では適用されない
- 適切なリファラー設定で外部サービス制限を回避
- セキュリティを考慮したドメイン制限の重要性

### 2. 外部API連携のベストプラクティス
- Service Object による責任分離
- エラーハンドリングの統一
- フォールバック機能の実装

### 3. フロントエンド統合の実践
- Stimulus による統合制御
- レスポンシブUX設計
- バリデーション回避テクニック

## API仕様

### 楽天商品検索API
```ruby
# エンドポイント
POST /api/rakuten/search_products

# リクエスト
{
  "title": "商品名 or 楽天URL"
}

# レスポンス
{
  "products": [
    {
      "title": "商品名",
      "image_url": "https://thumbnail.image.rakuten.co.jp/...",
      "rakuten_url": "https://item.rakuten.co.jp/...",
      "price": 1000
    }
  ],
  "success": true
}
```

この実装により、楽天APIとの堅牢で使いやすい連携機能を実現しています。