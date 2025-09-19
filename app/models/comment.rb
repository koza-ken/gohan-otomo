class Comment < ApplicationRecord
  include TimeFormatter

  belongs_to :user
  belongs_to :post

  validates :content, presence: true, length: { maximum: 300 }

  # 特定のユーザーがこのコメントを削除できるかチェック
  def deletable_by?(user)
    return false unless user

    # コメント作成者本人のみ削除可能
    self.user == user
  end

  # TimeFormatterモジュールのメソッドを使用
end
