class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # 同一ユーザーが同じ投稿に重複していいねできないようにバリデーション
  validates :user_id, uniqueness: { scope: :post_id, message: "既にこの投稿にいいねしています" }

  # 必須フィールドのバリデーション（belongs_toで暗黙的に設定されるが明示的に記述）
  validates :user, presence: { message: "ユーザーが必要です" }
  validates :post, presence: { message: "投稿が必要です" }
end
