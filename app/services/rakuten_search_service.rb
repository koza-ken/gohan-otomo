# frozen_string_literal: true

# 楽天商品検索のビジネスロジックを担当するサービスクラス
# コントローラーから切り出した検索・バリデーション処理
#
# メソッド関連図:
# RakutenSearchService
# │
# ├── 【外部インターフェース】
# │   ├── initialize(input, user)          # 初期化
# │   └── call                             # メイン処理 ★エントリーポイント
# │       │
# │       ├──→ validate_input              # 入力検証
# │       │    │
# │       │    ├──→ determine_search_type  # URL/キーワード判定
# │       │    └──→ error_result          # バリデーションエラー時
# │       │
# │       ├──→ perform_search             # 検索実行
# │       │    │
# │       │    ├──→ RakutenProductService.fetch_product_from_url
# │       │    ├──→ RakutenProductService.fetch_product_candidates
# │       │    ├──→ success_result        # 成功時
# │       │    └──→ success_result        # 結果なし時（メッセージ付き）
# │       │
# │       └──→ error_result               # 例外発生時
# │
# ├── 【結果生成ヘルパー】
# │   ├── success_result(products, count, message)  # 成功Result生成
# │   │    └──→ Result.new
# │   │
# │   └── error_result(error_message)              # エラーResult生成
# │        └──→ Result.new
# │
# └── 【データ構造】
#     └── Result (内部クラス)              # 結果オブジェクト
#         ├── to_json_response            # JSON変換
#         ├── http_status                 # HTTPステータス
#         ├── success_json                # 成功JSON
#         ├── error_json                  # エラーJSON
#         └── search_type_string          # 検索タイプ文字列


class RakutenSearchService
  # 結果オブジェクト（JSON生成機能付き）
  Result = Struct.new(:success?, :products, :count, :search_type, :error, :message, keyword_init: true) do
    def to_json_response
      if success?
        success_json
      else
        error_json
      end
    end

    def http_status
      success? ? :ok : :bad_request
    end

    private

    def success_json
      {
        success: true,
        products: products,
        count: count,
        search_type: search_type_string,
        timestamp: Time.current.iso8601
      }.tap do |json|
        json[:message] = message if message.present?
      end
    end

    def error_json
      {
        success: false,
        error: error,
        search_type: search_type_string,
        timestamp: Time.current.iso8601
      }
    end

    def search_type_string
      case search_type
      when :url then "url"
      when :keyword then "keyword"
      else "unknown"
      end
    end
  end

  def initialize(input, user)
    @input = input&.strip
    @user = user
    @search_type = nil
  end

  def call
    Rails.logger.info "API商品検索開始: user_id=#{@user.id}, input=#{@input}"

    # バリデーション
    validation_result = validate_input
    return validation_result unless validation_result.success?

    # 検索実行
    perform_search
  rescue => e
    Rails.logger.error "楽天API検索エラー: #{e.class} - #{e.message}"
    error_result("API接続エラーが発生しました。しばらく経ってから再試行してください。")
  end

  private

  def validate_input
    if @input.blank?
      return error_result("商品名またはURLを入力してください")
    end

    @search_type = determine_search_type
    max_length = @search_type == :url ? 1000 : 100

    Rails.logger.info "入力長: #{@input.length}文字, 検索タイプ: #{@search_type}, 制限: #{max_length}文字"

    if @input.length > max_length
      error_message = @search_type == :url ?
        "URLは1000文字以内で入力してください" :
        "商品名は100文字以内で入力してください"

      Rails.logger.error "文字数超過: #{@input.length}文字 > #{max_length}文字"
      return error_result(error_message)
    end

    success_result([], 0) # バリデーション成功の仮結果
  end

  def determine_search_type
    if @input.match?(%r{https?://(?:www\.|item\.)?rakuten\.co\.jp/})
      Rails.logger.info "🔗 楽天URL検索モード"
      :url
    else
      Rails.logger.info "🔍 商品名検索モード"
      :keyword
    end
  end

  def perform_search
    products = if @search_type == :url
      RakutenProductService.fetch_product_from_url(@input)
    else
      RakutenProductService.fetch_product_candidates(@input, limit: 12)
    end

    if products.any?
      Rails.logger.info "API商品検索成功: #{products.count}件取得"
      success_result(products, products.count)
    else
      Rails.logger.info "API商品検索: 結果なし"
      no_results_message = @search_type == :url ?
        "指定されたURLの商品が見つかりませんでした" :
        "「#{@input}」に該当する商品が見つかりませんでした"

      success_result([], 0, no_results_message)
    end
  end

  def success_result(products, count, message = nil)
    Result.new(
      success?: true,
      products: products,
      count: count,
      search_type: @search_type,
      message: message
    )
  end

  def error_result(error_message)
    Result.new(
      success?: false,
      error: error_message,
      products: [],
      count: 0,
      search_type: @search_type
    )
  end
end
