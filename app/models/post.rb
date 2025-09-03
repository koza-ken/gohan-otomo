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
end
