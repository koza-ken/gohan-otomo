class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :nullify
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  # バリデーション
  validates :display_name, presence: true, length: { maximum: 20 }
  validates :display_name, uniqueness: { case_sensitive: false }
  validates :favorite_foods, length: { maximum: 200 }
  validates :disliked_foods, length: { maximum: 200 }

  # いいねした投稿数を取得（Postモデルと統一的なインターフェース）
  delegate :count, to: :liked_posts, prefix: true

  # このユーザーが行ったいいね総数
  delegate :count, to: :likes, prefix: true
end
