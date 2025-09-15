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
    result = RakutenSearchService.new(params[:title], current_user).call
    render json: result.to_json_response, status: result.http_status
  end

  # 楽天画像をプロキシ経由で取得（CORS回避）
  #
  # GET /api/rakuten/proxy_image?url=...
  # 楽天ドメインの画像のみ許可、適切なヘッダーを設定してレスポンス
  def proxy_image
    image_url = params[:url]

    # セキュリティ：楽天ドメインのみ許可
    unless image_url.match?(%r{^https://thumbnail\.image\.rakuten\.co\.jp/})
      render json: { error: '許可されていない画像URLです' }, status: :forbidden
      return
    end

    begin
      uri = URI.parse(image_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.path + (uri.query ? "?#{uri.query}" : ""))
      # リファラーを楽天ドメインに設定
      request['Referer'] = 'https://www.rakuten.co.jp/'
      request['User-Agent'] = 'Mozilla/5.0 (compatible; RakutenImageProxy/1.0)'

      response = http.request(request)

      if response.code == '200'
        send_data response.body,
                  type: response.content_type || 'image/jpeg',
                  disposition: 'inline'
      else
        render json: { error: '画像の取得に失敗しました' }, status: :not_found
      end
    rescue => e
      Rails.logger.error "画像プロキシエラー: #{e.message}"
      render json: { error: '画像の取得に失敗しました' }, status: :internal_server_error
    end
  end
end