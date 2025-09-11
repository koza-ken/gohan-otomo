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

  # 投稿画像を表示するヘルパーメソッド（シンプル版）
  # まずは基本的な機能から実装
  def post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ""
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium  # 新しくsizeオプションを追加

    # Modelのdisplay_imageメソッドに優先順位制御を委譲
    image_source = post.display_image(size)

    if image_source.present?
      # 画像が存在する場合（Active Storage variant または 外部URL）
      if image_source.is_a?(ActiveStorage::VariantWithRecord)
        # Active Storage variant の場合
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
      base_message = "「#{post.title}」がおすすめ！！"
    else
      # 他人の投稿の場合
      base_message = "「#{post.title}」が気になる！！"
    end

    # カスタムメッセージがある場合は優先
    custom_message = options[:message]
    final_message = custom_message || base_message

    "#{final_message} #お供だち #ごはんのお供"
  end

  # WebP対応ブラウザかどうかを判定
  def supports_webp?
    return false unless request.present?
    
    accept_header = request.headers['HTTP_ACCEPT'] || ''
    accept_header.include?('image/webp')
  end

  # WebP対応画像表示ヘルパー（シンプル版）
  def optimized_post_image_tag(post, options = {})
    css_class = options[:class] || ""
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium

    # WebP対応ブラウザかつ画像添付ありの場合はWebP版を使用
    if supports_webp? && post.image.attached?
      case size
      when :thumbnail
        webp_variant = post.thumbnail_image_webp
      when :medium, :large
        webp_variant = post.medium_image_webp
      end

      return image_tag(webp_variant, alt: alt_text, class: css_class) if webp_variant
    end

    # フォールバック: 従来の画像表示（非対応ブラウザ、外部URL、プレースホルダー）
    post_image_tag(post, options)
  end

end
