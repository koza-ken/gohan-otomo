# 🔧 Service Object パターン - 完全復習ガイド

## 概要

**Service Object** は、Rails のコントローラーから複雑なビジネスロジックを分離するデザインパターン。
単一責任原則に基づき、1つのサービスが1つの具体的な業務処理を担当します。

### 基本的な特徴
- **単一責任原則**: 1つのサービス = 1つの責任
- **テスト容易性**: ビジネスロジックの独立テストが可能
- **再利用性**: 複数のコントローラーから共通利用可能
- **保守性**: ロジックの場所が明確で修正しやすい

## このアプリでの役割

### 🎯 **なぜ必要だったのか**

#### **1. ファットコントローラー問題**
```ruby
# 問題のあったコード（166行のファットコントローラー）
class Api::Rakuten::ProductsController < ApplicationController
  def search_products
    # バリデーション処理（20行）
    # 楽天API呼び出し（30行）
    # URL解析処理（25行）
    # エラーハンドリング（15行）
    # レスポンス生成（30行）
    # ログ出力（15行）
    # セキュリティチェック（20行）
    # その他の処理（11行）
  end
end
```

#### **2. Rails ベストプラクティス違反**
- **Controller**: HTTP処理のみに集中すべき
- **Model**: データ永続化のみに集中すべき
- **複雑なビジネスロジック**: 専用の場所が必要

### 💡 **Service Object による解決**

#### **Before（ファットコントローラー）**
- **166行の巨大メソッド**
- **複数の責任が混在**
- **テスト困難**
- **再利用不可**

#### **After（Service Object分離）**
- **Controller**: 2行のシンプル実装
- **Service**: 責任分離されたビジネスロジック
- **結果**: 99%削減（166行→2行）

## 実装内容

### 🏗️ **1. RakutenSearchService（メインサービス）**

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
      fetch_from_url
    else
      fetch_from_search
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

  def fetch_from_url
    RakutenProductService.fetch_product_from_url(@input)
  end

  def fetch_from_search
    RakutenProductService.fetch_product_candidates(@input, limit: 12)
  end

  def invalid_input_result
    SearchResult.new(products: [], success: false, error: "検索キーワードを入力してください")
  end

  def error_result(message)
    SearchResult.new(products: [], success: false, error: message)
  end
end
```

### 🎭 **2. SearchResult（Result Object）**

```ruby
# app/services/search_result.rb
class SearchResult
  attr_reader :products, :success, :error

  def initialize(products:, success:, error: nil)
    @products = products
    @success = success
    @error = error
  end

  def success?
    @success
  end

  def to_json_response
    if success?
      {
        success: true,
        products: products
      }
    else
      {
        success: false,
        error: error,
        products: []
      }
    end
  end

  def http_status
    success? ? :ok : :unprocessable_entity
  end
end
```

### 🎮 **3. Controller（Service Object 使用）**

```ruby
# app/controllers/api/rakuten/products_controller.rb
class Api::Rakuten::ProductsController < ApplicationController
  before_action :authenticate_user!

  def search_products
    result = RakutenSearchService.new(params[:title], current_user).call
    render json: result.to_json_response, status: result.http_status
  end

  # その他のアクション...
end
```

## 学習ポイント

### 🎯 **1. Service Object の設計原則**

#### **Single Responsibility（単一責任）**
```ruby
# ✅ 良い例：1つの責任
class UserRegistrationService
  def call
    # ユーザー登録のみ
  end
end

# ❌ 悪い例：複数の責任
class UserService
  def register_user    # 登録
  def send_email       # メール送信
  def generate_report  # レポート生成
  end
end
```

#### **Call Interface（統一インターフェース）**
```ruby
# 全てのServiceで統一された呼び出し方
service = SomeService.new(params)
result = service.call
```

#### **Result Object（結果オブジェクト）**
```ruby
# 成功/失敗を明確に表現
result = service.call

if result.success?
  # 成功時の処理
  render json: result.data
else
  # 失敗時の処理
  render json: { error: result.error }
end
```

### 🔧 **2. エラーハンドリングの統一**

```ruby
class SomeService
  def call
    # ビジネスロジック
    success_result(data)
  rescue SomeSpecificError => e
    Rails.logger.error "特定エラー: #{e.message}"
    error_result("ユーザー向けメッセージ")
  rescue => e
    Rails.logger.error "予期しないエラー: #{e.message}"
    error_result("システムエラーが発生しました")
  end

  private

  def success_result(data)
    Result.new(success: true, data: data)
  end

  def error_result(message)
    Result.new(success: false, error: message)
  end
end
```

### 🧪 **3. テスト戦略**

#### **Service 単体テスト**
```ruby
# spec/services/rakuten_search_service_spec.rb
RSpec.describe RakutenSearchService, type: :service do
  describe '#call' do
    context '商品名検索の場合' do
      it '商品候補を正常に取得できる' do
        service = RakutenSearchService.new('おにぎり', user)
        result = service.call

        expect(result.success?).to be true
        expect(result.products).not_to be_empty
      end
    end

    context 'URL検索の場合' do
      it '楽天URLから商品を取得できる' do
        url = 'https://item.rakuten.co.jp/shop/item'
        service = RakutenSearchService.new(url, user)
        result = service.call

        expect(result.success?).to be true
      end
    end

    context 'エラーの場合' do
      it '適切なエラーメッセージを返す' do
        service = RakutenSearchService.new('', user)
        result = service.call

        expect(result.success?).to be false
        expect(result.error).to eq "検索キーワードを入力してください"
      end
    end
  end
end
```

#### **Controller テスト（簡潔になる）**
```ruby
# spec/requests/api/rakuten/products_spec.rb
RSpec.describe 'Api::Rakuten::Products', type: :request do
  describe 'POST /api/rakuten/search_products' do
    it 'サービスを呼び出してレスポンスを返す' do
      # サービスのモックを設定
      allow(RakutenSearchService).to receive_message_chain(:new, :call)
        .and_return(double(to_json_response: {}, http_status: :ok))

      post '/api/rakuten/search_products', params: { title: 'test' }

      expect(response).to have_http_status(:ok)
    end
  end
end
```

### 🏛️ **4. アーキテクチャパターン**

```
Controller
    ↓ (呼び出し)
Service Object
    ↓ (使用)
Model / External API
    ↓ (結果)
Result Object
    ↓ (返却)
Controller
    ↓ (レンダリング)
View / JSON Response
```

## 関連ファイル

### 🔧 **Service ファイル**
```
app/services/
├── rakuten_search_service.rb       # メイン検索サービス
├── rakuten_product_service.rb      # 楽天API基本機能
└── search_result.rb                # Result Object
```

### 🧪 **テストファイル**
```
spec/services/
├── rakuten_search_service_spec.rb  # サービステスト
└── rakuten_product_service_spec.rb # 基本機能テスト（15例）
```

### 🎮 **Controller ファイル**
```
app/controllers/api/rakuten/
└── products_controller.rb          # 簡潔なコントローラー（2行実装）
```

### 📋 **設定ファイル**
```
config/application.rb               # サービス層の autoload 設定
├── app/services の自動読み込み
└── ファイル命名規約の設定
```

## 他プロジェクトでの応用

### 🔄 **汎用的なService Object パターン**

#### **1. 基本的なサービス構造**
```ruby
class BaseService
  def initialize(params)
    @params = params
  end

  def call
    # バリデーション
    # ビジネスロジック実行
    # 結果返却
  rescue => e
    handle_error(e)
  end

  private

  def handle_error(error)
    Rails.logger.error "#{self.class.name}エラー: #{error.message}"
    error_result(error.message)
  end

  def success_result(data)
    # Result Object 生成
  end

  def error_result(message)
    # Error Result Object 生成
  end
end
```

#### **2. 外部API連携サービス**
```ruby
class ExternalApiService < BaseService
  def call
    response = call_external_api
    parse_response(response)
  rescue Net::TimeoutError
    error_result("API接続がタイムアウトしました")
  rescue => e
    handle_error(e)
  end
end
```

#### **3. バッチ処理サービス**
```ruby
class BatchProcessService < BaseService
  def call
    process_items
    success_result(processed_count: @count)
  rescue => e
    cleanup_on_error
    handle_error(e)
  end
end
```

#### **4. ファイル処理サービス**
```ruby
class FileProcessService < BaseService
  def call
    validate_file
    process_file
    success_result(file_path: @processed_file)
  rescue FileValidationError => e
    error_result(e.message)
  end
end
```

### 🎁 **再利用可能コンポーネント**
- **Result Object**: 全サービスで共通利用
- **エラーハンドリング**: 統一されたエラー処理パターン
- **ログ出力**: 一貫したログ形式
- **バリデーション**: 共通バリデーションロジック

### 🔧 **実装ガイドライン**
1. **命名規約**: `何をするService`（例：UserRegistrationService）
2. **ファイル配置**: `app/services/`配下
3. **テスト配置**: `spec/services/`配下
4. **インターフェース**: `initialize` + `call` メソッド
5. **戻り値**: Result Object で統一

---

**Service Object パターンは、お供だちアプリの保守性・テスト性・再利用性を劇的に向上させ、
Rails アプリケーションのアーキテクチャ設計における重要な技術基盤となっています。**