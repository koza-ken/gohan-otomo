# frozen_string_literal: true

# 楽天商品検索APIとの連携を行うサービスクラス
# 商品名から商品候補を検索し、投稿フォーム用のデータ構造に変換
class RakutenProductService
  # デフォルト設定
  DEFAULT_LIMIT = 5
  TIMEOUT_SECONDS = 10

  # 商品名で楽天商品を検索し、候補リストを返す
  #
  # @param title [String] 検索する商品名
  # @param limit [Integer] 取得する商品数の上限（デフォルト: 5）
  # @return [Array<Hash>] 商品情報のハッシュ配列
  def self.fetch_product_candidates(title, limit: DEFAULT_LIMIT)
    return [] if title.blank?

    begin
      Rails.logger.info "🛒 楽天API検索開始: #{title}"
      
      # 楽天商品検索API呼び出し
      items = RakutenWebService::Ichiba::Item.search(
        keyword: title,
        hits: limit
      )

      # 検索結果を構造化
      products = items.map do |item|
        format_product_info(item)
      end

      Rails.logger.info "✅ 楽天API検索成功: #{products.count}件取得"
      products

    rescue Net::TimeoutError => e
      Rails.logger.error "⏰ 楽天API タイムアウト: #{e.message}"
      []
    rescue StandardError => e
      Rails.logger.error "❌ 楽天API検索エラー: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      []
    end
  end

  private

  # 楽天APIの商品データを投稿フォーム用の形式に変換
  #
  # @param rakuten_item [RakutenWebService::Ichiba::Item] 楽天商品オブジェクト
  # @return [Hash] 投稿フォーム用の商品情報
  def self.format_product_info(rakuten_item)
    {
      title: rakuten_item.name,                      # 商品名
      description: strip_html(rakuten_item.caption), # 商品説明（HTMLタグ除去）
      image_url: get_first_image_url(rakuten_item),  # 画像URL
      price: rakuten_item.price,                     # 価格
      rakuten_url: rakuten_item.url,                 # 商品URL
      shop_name: rakuten_item.shop_name              # ショップ名
    }
  end

  # 商品の最初の画像URLを取得
  #
  # @param item [RakutenWebService::Ichiba::Item] 楽天商品オブジェクト
  # @return [String, nil] 画像URL、または nil
  def self.get_first_image_url(item)
    return nil unless item.medium_image_urls&.any?
    
    image_data = item.medium_image_urls.first
    return nil unless image_data.is_a?(Hash)
    
    image_data["imageUrl"]
  end

  # HTML文字列からタグを除去してプレーンテキストに変換
  #
  # @param html [String, nil] HTML文字列
  # @return [String, nil] プレーンテキスト
  def self.strip_html(html)
    return nil if html.blank?
    
    # HTMLタグを除去し、連続した空白を単一空白に変換
    html.gsub(/<\/?[^>]*>/, '')
        .gsub(/\s+/, ' ')
        .strip
  end
end