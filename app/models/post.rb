class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user

  # Active Storage: 画像アップロード機能
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 200 }
  validates :link, length: { maximum: 500 }, allow_blank: true
  validates :link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "正しいURLを入力してください" }, if: :link?
  validates :image_url, length: { maximum: 500 }, allow_blank: true
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "正しいURLを入力してください" }, if: :image_url?

  # 画像バリデーション
  validate :image_format
  validate :image_size

  # counter_cache導入時のカラム名でメソッドを定義
  def comments_count
    comments.count
  end

  # セキュアなリンクを返すメソッド（javascript:スキームなどを防ぐ）
  def safe_link
    return nil if link.blank?

    # javascript:、data:、vbscript:などの危険なスキームをチェック
    uri = URI.parse(link)
    return nil unless %w[http https].include?(uri.scheme&.downcase)

    link
  rescue URI::InvalidURIError
    nil
  end

  # Active Storage variant: サムネイル画像（投稿一覧用）
  def thumbnail_image
    return nil unless image.attached?

    image.variant(resize_to_fill: [ 400, 300 ], quality: 85)
  end

  # Active Storage variant: 中サイズ画像（投稿詳細用）
  def medium_image
    return nil unless image.attached?

    image.variant(resize_to_fill: [ 800, 600 ], quality: 85)
  end

  # ハイブリッド画像表示: 優先順位に従って適切な画像を返す
  # 1. Active Storageの画像（最優先）
  # 2. image_urlの外部画像（次優先）
  # 3. プレースホルダー（最終手段）
  def display_image(size = :medium)
    case size
    when :thumbnail
      return thumbnail_image if image.attached?
    when :medium, :large
      return medium_image if image.attached?
    end

    # Active Storageに画像がない場合は外部URLを使用
    image_url.presence
  end

  # 画像が存在するかチェック
  def has_image?
    image.attached? || image_url.present?
  end

  private

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
