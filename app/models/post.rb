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
  validates :link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "正しいURLを入力してください" }, if: :link?
  validates :image_url, length: { maximum: 1000 }, allow_blank: true
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "正しいURLを入力してください" }, if: :image_url?

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

  # WebP形式のvariant: サムネイル画像（投稿一覧用）
  def thumbnail_image_webp
    return nil unless image.attached?

    image.variant(resize_to_fill: [ 400, 300 ], quality: 85, format: :webp)
  end

  # WebP形式のvariant: 中サイズ画像（投稿詳細用）
  def medium_image_webp
    return nil unless image.attached?

    image.variant(resize_to_fill: [ 800, 600 ], quality: 85, format: :webp)
  end

  # ハイブリッド画像表示: ユーザーの選択に基づく画像表示
  # image_source フィールド: 'url', 'file'
  # 1. ユーザー選択優先（image_sourceに基づく）
  # 2. フォールバック: URL画像 → ファイル画像の順
  def display_image(size = :medium, webp_support = false)
    # image_sourceが明示的に設定されている場合は、それに従う
    if respond_to?(:image_source) && image_source.present?
      case image_source
      when 'url'
        return image_url if image_url.present?
      when 'file'
        if image.attached?
          return get_file_image(size, webp_support)
        end
      end
    end

    # フォールバック: URL画像を優先、次にファイル画像
    return image_url if image_url.present?
    
    if image.attached?
      return get_file_image(size, webp_support)
    end

    # 両方ともない場合はnilを返す（プレースホルダーは呼び出し元で処理）
    nil
  end

  # 画像が存在するかチェック
  def has_image?
    image.attached? || image_url.present?
  end

  private

  # ファイル画像の取得（サイズ・WebP対応）
  def get_file_image(size, webp_support)
    case size
    when :thumbnail
      return webp_support ? thumbnail_image_webp : thumbnail_image
    when :medium, :large
      return webp_support ? medium_image_webp : medium_image
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
