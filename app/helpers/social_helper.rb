module SocialHelper
  # X投稿ボタンを生成するヘルパーメソッド
  def x_share_button(post, options = {})
    # 投稿用のテキストを生成（投稿者判定あり）
    share_text = generate_share_text(post, options)
    # 投稿詳細ページのURL
    post_url = post_url(post)
    # X Web Intents APIのURL
    x_intent_url = "https://twitter.com/intent/tweet?text=#{CGI.escape(share_text)}&url=#{CGI.escape(post_url)}"

    # ボタンテキストを投稿者判定で変更
    button_text = if user_signed_in? && current_user == post.user
                    "おすすめ"  # 自分の投稿
    else
                    "気になる"  # 他人の投稿
    end

    # デフォルトのCSSクラス（お米テーマに合わせたデザイン）
    default_class = "inline-flex items-center gap-2 px-3 py-1 bg-black hover:bg-black/60 text-white rounded-lg transition-colors duration-200"
    css_class = options[:class] || default_class

    link_to(x_intent_url,
            target: "_blank",
            rel: "noopener noreferrer",
            class: css_class,
            data: { turbo: false }) do
      content_tag(:span, "𝕏", class: "text-sm font-bold") +
      content_tag(:span, button_text, class: "text-sm")
    end
  end

  private

  # X投稿用のテキストを生成（投稿者判定あり）
  def generate_share_text(post, options = {})
    # 投稿者判定でメッセージを変更
    if user_signed_in? && current_user == post.user
      # 自分の投稿の場合
      base_message = "白いごはんには\"#{post.title}\"がおすすめ！！"
    else
      # 他人の投稿の場合
      base_message = "\"#{post.title}\"が気になる！おいしそう！！"
    end

    # カスタムメッセージがある場合は優先
    custom_message = options[:message]
    final_message = custom_message || base_message

    "#{final_message} #お供だち #ごはんのお供"
  end
end