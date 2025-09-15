# frozen_string_literal: true

# 楽天商品検索APIとの連携を行うサービスクラス
# 商品名から商品候補を検索し、投稿フォーム用のデータ構造に変換
class RakutenProductService
  # デフォルト設定
  DEFAULT_LIMIT = 12
  TIMEOUT_SECONDS = 10

  # 楽天市場URLから商品情報を取得する
  #
  # @param rakuten_url [String] 楽天市場の商品URL
  # @return [Array<Hash>] 商品情報のハッシュ配列（1件または空配列）
  def self.fetch_product_from_url(rakuten_url)
    return [] if rakuten_url.blank?

    # 楽天URLの正規表現パターン（商品ID部分を抽出）
    rakuten_patterns = [
      # https://item.rakuten.co.jp/shop-name/item-code/
      %r{https?://(?:www\.)?item\.rakuten\.co\.jp/([^/]+)/([^/?]+)},
      # https://www.rakuten.co.jp/shop-name/cabinet/item-code.html
      %r{https?://(?:www\.)?rakuten\.co\.jp/([^/]+)/cabinet/([^/?]+)\.html}
    ]

    shop_code = nil
    item_code = nil

    rakuten_patterns.each do |pattern|
      match = rakuten_url.match(pattern)
      if match
        shop_code = match[1]
        item_code = match[2].gsub(/\.html$/, '') # .htmlを除去
        break
      end
    end

    return [] unless shop_code && item_code

    begin
      Rails.logger.info "🛒 楽天URL解析開始: shop_code=#{shop_code}, item_code=#{item_code}"

      items = []

      # 段階1: 正確な検索（shop_code + item_code）
      begin
        Rails.logger.info "🔍 段階1: 正確検索 (shop_code + item_code)"
        items = RakutenWebService::Ichiba::Item.search(
          shop_code: shop_code,
          item_code: item_code
        )
        Rails.logger.info "✅ 正確検索結果: #{items.count}件"
      rescue StandardError => e
        Rails.logger.info "⚠️ 正確検索失敗: #{e.message} → 部分検索に移行"
        items = []
      end

      # 段階2: 部分検索（keyword + shop_code）
      if items.count == 0
        begin
          Rails.logger.info "🔍 段階2: 部分検索 (keyword + shop_code)"
          items = RakutenWebService::Ichiba::Item.search(
            keyword: item_code,
            shop_code: shop_code
          )
          Rails.logger.info "✅ 部分検索結果: #{items.count}件"
        rescue StandardError => e
          Rails.logger.info "⚠️ 部分検索失敗: #{e.message} → キーワード検索に移行"
          items = []
        end
      end

      # 段階3: キーワード検索のみ（最終フォールバック）
      if items.count == 0
        begin
          Rails.logger.info "🔍 段階3: キーワード検索のみ (最終フォールバック)"
          items = RakutenWebService::Ichiba::Item.search(
            keyword: item_code
          )
          Rails.logger.info "✅ キーワード検索結果: #{items.count}件"
        rescue StandardError => e
          Rails.logger.warn "⚠️ 最終検索も失敗: #{e.message}"
          items = []
        end
      end

      item = items.first
      return [] unless item

      product_info = format_product_info(item)
      Rails.logger.info "✅ 楽天URL解析成功: #{product_info[:title]}"

      [product_info] # 配列形式で返す（既存のAPIと統一）

    rescue StandardError => e
      Rails.logger.error "❌ 楽天URL解析 致命的エラー: #{e.message}"
      Rails.logger.error e.backtrace.first(3).join("\n")
      []
    end
  end

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

    rescue Timeout::Error => e
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

  # 商品の最初の画像URLを取得（高画質優先・URLパラメータ最適化）
  #
  # @param item [RakutenWebService::Ichiba::Item] 楽天商品オブジェクト
  # @return [String, nil] 画像URL、または nil
  def self.get_first_image_url(item)
    # 方法1: medium_image_urls から取得してパラメータ最適化（400x400px）
    if item.medium_image_urls&.any?
      image_url = item.medium_image_urls.first
      if image_url.is_a?(String) && image_url.present?
        # URLパラメータを128x128から400x400に変更して高画質化
        high_quality_url = image_url.gsub(/_ex=\d+x\d+/, "_ex=400x400")
        Rails.logger.debug { "✅ 画像URL取得成功（高画質化）: #{item.name} → 400x400" }
        return high_quality_url
      end
    end

    # 方法3: small_image_urls から取得（低画質 64x64px）
    if item.respond_to?(:small_image_urls) && item.small_image_urls&.any?
      image_url = item.small_image_urls.first
      if image_url.is_a?(String) && image_url.present?
        Rails.logger.debug { "✅ 画像URL取得成功（small）: #{item.name}" }
        return image_url
      end
    end

    # 最終フォールバック: 直接image_urlプロパティ
    if item.respond_to?(:image_url) && item.image_url.present?
      Rails.logger.debug { "✅ 画像URL取得成功（直接）: #{item.name}" }
      return item.image_url
    end

    Rails.logger.warn "⚠️ 画像URL取得失敗: #{item.name}"
    nil
  end

  # HTML文字列からタグを除去してプレーンテキストに変換
  #
  # @param html [String, nil] HTML文字列
  # @return [String, nil] プレーンテキスト
  def self.strip_html(html)
    return nil if html.blank?

    # HTMLタグを除去し、連続した空白を単一空白に変換
    html.gsub(/<\/?[^>]*>/, "")
        .gsub(/\s+/, " ")
        .strip
  end
end
