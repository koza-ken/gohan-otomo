# frozen_string_literal: true

# 楽天商品検索API エンドポイント
# フロントエンドから商品検索リクエストを受け取り、JSON で商品候補を返す
class Api::Rakuten::ProductsController < ApplicationController
  # CSRF保護を無効化（API用）
  skip_before_action :verify_authenticity_token

  # 認証必須（ログインユーザーのみAPI利用可能）
  before_action :authenticate_user!

  # 商品名または楽天URLで楽天商品を検索し、候補リストをJSONで返す
  #
  # POST /api/rakuten/search_products
  # params: { title: "商品名またはURL" }
  # response: { success: true, products: [...] } または { success: false, error: "..." }
  def search_products
    input = params[:title]&.strip

    # バリデーション
    if input.blank?
      render json: {
        success: false,
        error: "商品名またはURLを入力してください"
      }, status: :bad_request
      return
    end

    begin
      Rails.logger.info "API商品検索開始: user_id=#{current_user.id}, input=#{input}"
      Rails.logger.info "入力長: #{input.length}文字"

      # 入力がURLかどうかを判定（より厳密にチェック）
      is_rakuten_url = input.match?(%r{https?://(?:www\.|item\.)?rakuten\.co\.jp/})
      Rails.logger.info "URL判定: #{is_rakuten_url ? 'URL' : '商品名'}"

      # URLと商品名で異なる文字数制限
      max_length = is_rakuten_url ? 1000 : 100
      Rails.logger.info "文字数制限: #{max_length}文字"

      if input.length > max_length
        error_message = is_rakuten_url ?
          "URLは1000文字以内で入力してください" :
          "商品名は100文字以内で入力してください"

        Rails.logger.error "文字数超過: #{input.length}文字 > #{max_length}文字"

        render json: {
          success: false,
          error: error_message
        }, status: :bad_request
        return
      end

      # URLまたは商品名で検索
      products = if is_rakuten_url
        Rails.logger.info "🔗 楽天URL検索モード"
        RakutenProductService.fetch_product_from_url(input)
      else
        Rails.logger.info "🔍 商品名検索モード"
        RakutenProductService.fetch_product_candidates(input, limit: 12)
      end

      if products.any?
        Rails.logger.info "API商品検索成功: #{products.count}件取得"

        render json: {
          success: true,
          products: products,
          count: products.count,
          search_type: is_rakuten_url ? 'url' : 'keyword'
        }
      else
        Rails.logger.info "API商品検索: 結果なし"

        error_message = if is_rakuten_url
          "指定されたURLの商品が見つかりませんでした"
        else
          "「#{input}」に該当する商品が見つかりませんでした"
        end

        render json: {
          success: true,
          products: [],
          count: 0,
          message: error_message,
          search_type: is_rakuten_url ? 'url' : 'keyword'
        }
      end

    rescue => e
      Rails.logger.error "API商品検索エラー: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")

      render json: {
        success: false,
        error: "サーバーエラーが発生しました。時間をおいて再試行してください。"
      }, status: :internal_server_error
    end
  end

  # 楽天画像のCORSエラーを回避するためのプロキシエンドポイント
  #
  # GET /api/rakuten/proxy_image?url=https://...
  def proxy_image
    image_url = params[:url]

    # バリデーション
    if image_url.blank?
      render json: { error: "画像URLが指定されていません" }, status: :bad_request
      return
    end

    # 楽天ドメインのみ許可（セキュリティ対策）
    unless image_url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
      render json: { error: "許可されていない画像URLです" }, status: :forbidden
      return
    end

    begin
      Rails.logger.debug { "🖼️ 画像プロキシ要求: #{image_url}" }

      # 楽天サーバーから画像を取得
      require "net/http"
      require "uri"

      uri = URI.parse(image_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.request_uri)
      # リファラーを楽天ドメインに設定
      request["Referer"] = "https://www.rakuten.co.jp/"
      request["User-Agent"] = "Mozilla/5.0 (compatible; RakutenImageProxy/1.0)"

      response = http.request(request)

      if response.code == "200"
        Rails.logger.debug { "✅ 画像プロキシ成功: #{response.content_type}, #{response.body.length}bytes" }

        # 画像データをそのまま返す
        send_data response.body,
                  type: response.content_type || "image/jpeg",
                  disposition: "inline",
                  filename: "rakuten_image.jpg"
      else
        Rails.logger.warn "⚠️ 画像プロキシ失敗: #{response.code} #{response.message}"
        head :not_found
      end

    rescue => e
      Rails.logger.error "❌ 画像プロキシエラー: #{e.message}"
      head :internal_server_error
    end
  end

  private

  # API専用のエラーハンドリング
  def handle_api_error(error, message = "エラーが発生しました")
    Rails.logger.error "API エラー: #{error.message}"
    render json: { success: false, error: message }, status: :internal_server_error
  end
end
