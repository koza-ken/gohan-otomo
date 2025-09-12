class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :content, presence: true, length: { maximum: 300 }

  # 特定のユーザーがこのコメントを削除できるかチェック
  def deletable_by?(user)
    return false unless user

    # コメント作成者本人のみ削除可能
    self.user == user
  end

  # 相対的な投稿時間を表示（例: "3分前", "2時間前"）
  def time_ago_in_words_japanese
    time_diff = Time.current - created_at

    case time_diff
    when 0..59
      "#{time_diff.to_i}秒前"
    when 60..3599
      "#{(time_diff / 60).to_i}分前"
    when 3600..86399
      "#{(time_diff / 3600).to_i}時間前"
    when 86400..2591999
      "#{(time_diff / 86400).to_i}日前"
    else
      created_at.strftime("%Y年%m月%d日")
    end
  end

  # コメント内容の表示用メソッド（改行対応）
  def formatted_content
    content.gsub(/\r\n|\r|\n/, "<br>").html_safe
  end
end
