class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  belongs_to :user

  # Active Storage: 画像アップロード機能
  has_one_attached :image

  # 仮想属性: 画像選択方法
  attr_accessor :image_source

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 200 }
  validates :link, length: { maximum: 1000 }, allow_blank: true
  validates :image_url, length: { maximum: 1000 }, allow_blank: true
  # リンクの入力が正しいか確認
  validates :link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "正しいURLを入力してください" }, if: :link?
  # 楽天ドメインのみ許可（セキュリティ対策）
  validates :image_url, format: {
    with: %r{\Ahttps://thumbnail\.image\.rakuten\.co\.jp/.*\z},
    message: "楽天市場の画像URLのみ使用できます"
  }, if: :image_url?

  # 画像バリデーション
  validate :image_format
  validate :image_size

  # 検索用スコープ
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    # ILIKEはPostgreSQL用、名前付きプレースホルダーでSQLインジェクション対策
    where(
      "title ILIKE :keyword OR description ILIKE :keyword",
      keyword: "%#{keyword}%"
    )
  }

  # counter_cache導入時のカラム名でメソッドを定義
  def comments_count
    comments.count
  end

  # いいね数を取得
  def likes_count
    likes.count
  end

  # 特定のユーザーがこの投稿にいいねしているかチェック
  def liked_by?(user)
    return false unless user

    likes.exists?(user: user)
  end

  # セキュアなリンクを返すメソッド（javascript:スキームなどを防ぐ）
  def safe_link
    return nil if link.blank?

    # javascript:（JSのコードが送られてきたらnilを返す）、data:、vbscript:などの危険なスキームをチェック
    # URI.parse("https://example.com/path") => #<URI::HTTPS https://example.com/path>
    uri = URI.parse(link)
    # uri.schemeは、urlの"https"部分のこと
    return nil unless %w[http https].include?(uri.scheme&.downcase)

    link
  # 不正なリンクが送られるとnilを返す
  rescue URI::InvalidURIError
    nil
  end

  # 投稿一覧用サムネイル画像（400x300）
  def thumbnail_image
    create_variant(400, 300)
  end

  # 投稿詳細用中サイズ画像（800x600）
  def medium_image
    create_variant(800, 600)
  end

  # WebP形式サムネイル画像（400x300）
  def thumbnail_image_webp
    create_variant(400, 300, format: :webp, fallback_method: :thumbnail_image)
  end

  # WebP形式中サイズ画像（800x600）
  def medium_image_webp
    create_variant(800, 600, format: :webp, fallback_method: :medium_image)
  end

  # ユーザー選択とフォールバックによるハイブリッド画像表示
  def display_image(size = :medium, webp_support = false)
    image_from_source_preference(size, webp_support) ||
    image_from_fallback(size, webp_support)
  end

  # 画像が存在するかチェック
  def has_image?
    image.attached? || image_url.present?
  end

  private

  # 画像variant生成の共通処理（エラーハンドリング付き）
  def create_variant(width, height, format: nil, fallback_method: nil)
    return nil unless image.attached?

    begin
      variant_options = { resize_to_fill: [width, height] }
      variant_options[:format] = format if format
      image.variant(variant_options).processed
    rescue ActiveStorage::IntegrityError => e
      # フォーマットの情報を整形（デバッグ用）
      format_suffix = format ? " #{format.to_s.upcase}" : ""
      # エラーログ出力（デバッグ用）
      Rails.logger.error "#{format_suffix} variant error (#{width}x#{height}): #{e.message}"
      fallback_method ? send(fallback_method) : image
    end
  end

  # ユーザー指定のimage_sourceに基づく画像取得
  def image_from_source_preference(size, webp_support)
    return unless respond_to?(:image_source) && image_source.present?

    case image_source
    when "url"
      image_url if image_url.present?
    when "file"
      get_file_image(size, webp_support) if image.attached?
    end
  end

  # フォールバック順序による画像取得（URL優先→ファイル）
  def image_from_fallback(size, webp_support)
    return image_url if image_url.present?
    get_file_image(size, webp_support) if image.attached?
  end

  # ファイル画像の取得（サイズ・WebP対応）
  def get_file_image(size, webp_support)
    case size
    when :thumbnail
      webp_support ? thumbnail_image_webp : thumbnail_image
    when :medium, :large
      webp_support ? medium_image_webp : medium_image
    end
  end

  # 画像形式のバリデーション
  def image_format
    return unless image.attached?

    unless image.content_type.in?([ "image/jpeg", "image/png", "image/webp", "image/gif" ])
      errors.add(:image, "画像はJPEG、PNG、WebP、GIF形式でアップロードしてください")
    end
  end

  # 画像サイズのバリデーション
  def image_size
    return unless image.attached?

    if image.byte_size > 10.megabytes
      errors.add(:image, "画像サイズは10MB以下でアップロードしてください")
    end
  end
end
