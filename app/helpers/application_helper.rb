module ApplicationHelper
  # アイコン表示ヘルパーメソッド
  def icon_tag(icon_name, options = {})
    css_class = options[:class] || "w-5 h-5"
    alt_text = options[:alt] || icon_name.to_s

    # SVGファイルとして表示
    image_tag("/icons/#{icon_name}.svg",
              alt: alt_text,
              class: css_class)
  end

  # 投稿画像を表示するヘルパーメソッド（picture要素 + WebP対応）
  def picture_post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ""
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium

    # Modelのdisplay_imageメソッドで、WebP版と従来版の画像を取得
    webp_image = post.display_image(size, true)   # WebP版
    fallback_image = post.display_image(size, false) # 従来版（JPEG/PNG）

    # 条件分岐によるHTML生成
    if webp_image.present? && fallback_image.present? &&
       webp_image.is_a?(ActiveStorage::VariantWithRecord) &&
       fallback_image.is_a?(ActiveStorage::VariantWithRecord)
      # Active Storage画像の場合：picture要素でWebP + 従来形式
      content_tag(:picture) do
        tag.source(srcset: url_for(webp_image), type: "image/webp") +
        tag.source(srcset: url_for(fallback_image), type: "image/jpeg") +
        image_tag(fallback_image, alt: alt_text, class: css_class)
      end
    elsif fallback_image.present?
      # 外部URL画像またはプレースホルダーの場合：通常のimg要素
      if fallback_image.is_a?(ActiveStorage::VariantWithRecord)
        image_tag(fallback_image, alt: alt_text, class: css_class)
      else
        # 外部URL画像（Stimulusエラーハンドリング付き）
        image_tag(fallback_image,
                  alt: alt_text,
                  class: css_class,
                  data: {
                    controller: "image-preview",
                    size: size,
                    action: "error->image-preview#handleImageError"
                  })
      end
    else
      # プレースホルダーを表示
      placeholder_image_tag(size, css_class)
    end
  end

  # 投稿画像を表示するヘルパーメソッド（WebP対応統合版・旧実装）
  def post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ""
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium

    # WebP対応ブラウザ判定を行い、統合されたdisplay_imageメソッドを呼び出し
    webp_support = supports_webp?
    image_source = post.display_image(size, webp_support)

    if image_source.present?
      # 画像が存在する場合（Active Storage variant または 外部URL）
      if image_source.is_a?(ActiveStorage::VariantWithRecord)
        # Active Storage variant の場合（JPEG/PNG/WebP対応）
        image_tag(image_source, alt: alt_text, class: css_class)
      else
        # 外部URL画像の場合（Stimulusエラーハンドリング付き）
        image_tag(image_source,
                  alt: alt_text,
                  class: css_class,
                  data: {
                    controller: "image-preview",
                    size: size,
                    action: "error->image-preview#handleImageError"
                  })
      end
    else
      # プレースホルダーを表示（サイズに応じて調整）
      placeholder_image_tag(size, css_class)
    end
  end

  private

  # プレースホルダー画像のHTMLを生成（WebP対応）
  def placeholder_image_tag(size, css_class)
    # WebP対応ブラウザなら軽量なWebP版を使用
    image_path = supports_webp? ? "/no_image.webp" : "/no_image.png"

    content_tag(:div,
                image_tag(image_path,
                          alt: "画像がありません",
                          class: "w-full h-full object-contain"),
                class: "flex items-center justify-center bg-orange-100 #{css_class}")
  end

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

  # WebP対応ブラウザかどうかを判定
  def supports_webp?
    return false if request.blank?

    accept_header = request.headers["HTTP_ACCEPT"] || ""
    accept_header.include?("image/webp")
  end
end
