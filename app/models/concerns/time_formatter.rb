module TimeFormatter
  extend ActiveSupport::Concern

  # 相対的な投稿時間を表示（例: "3分前", "2時間前"）
  def time_ago_in_words_japanese(timestamp = created_at)
    time_diff = Time.current - timestamp

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
      timestamp.strftime("%Y年%m月%d日")
    end
  end

  # フォーマット済みコンテンツの表示（改行対応）
  def formatted_content
    ActionController::Base.helpers.simple_format(content, {}, wrapper_tag: nil)
  end
end