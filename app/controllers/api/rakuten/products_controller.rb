# frozen_string_literal: true

# 楽天商品検索API エンドポイント
# フロントエンドから商品検索リクエストを受け取り、JSON で商品候補を返す
class Api::Rakuten::ProductsController < ApplicationController
  # CSRF保護を無効化（API用）
  skip_before_action :verify_authenticity_token
  
  # 認証必須（ログインユーザーのみAPI利用可能）
  before_action :authenticate_user!

  # 商品名で楽天商品を検索し、候補リストをJSONで返す
  #
  # POST /api/rakuten/search_products
  # params: { title: "商品名" }
  # response: { success: true, products: [...] } または { success: false, error: "..." }
  def search_products
    title = params[:title]&.strip
    
    # バリデーション
    if title.blank?
      render json: { 
        success: false, 
        error: '商品名を入力してください' 
      }, status: :bad_request
      return
    end

    if title.length > 100
      render json: { 
        success: false, 
        error: '商品名は100文字以内で入力してください' 
      }, status: :bad_request
      return
    end

    begin
      Rails.logger.info "API商品検索開始: user_id=#{current_user.id}, title=#{title}"
      
      # RakutenProductService を使用して商品検索
      products = RakutenProductService.fetch_product_candidates(title, limit: 5)
      
      if products.any?
        Rails.logger.info "API商品検索成功: #{products.count}件取得"
        
        render json: {
          success: true,
          products: products,
          count: products.count
        }
      else
        Rails.logger.info "API商品検索: 結果なし"
        
        render json: {
          success: true,
          products: [],
          count: 0,
          message: "「#{title}」に該当する商品が見つかりませんでした"
        }
      end
      
    rescue => e
      Rails.logger.error "API商品検索エラー: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      
      render json: { 
        success: false, 
        error: 'サーバーエラーが発生しました。時間をおいて再試行してください。' 
      }, status: :internal_server_error
    end
  end
  
  private
  
  # API専用のエラーハンドリング
  def handle_api_error(error, message = "エラーが発生しました")
    Rails.logger.error "API エラー: #{error.message}"
    render json: { success: false, error: message }, status: :internal_server_error
  end
end