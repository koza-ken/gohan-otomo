class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # バリデーション
  validates :display_name, presence: true, length: { maximum: 20 }
  validates :display_name, uniqueness: { case_sensitive: false }
  validates :favorite_foods, length: { maximum: 200 }
  validates :disliked_foods, length: { maximum: 200 }

end
