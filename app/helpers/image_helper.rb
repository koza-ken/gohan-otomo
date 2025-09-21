module ImageHelper
  # 投稿画像を表示するヘルパーメソッド（picture要素 + WebP対応）
  def picture_post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ""
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium

    # 直接WebPと通常版のvariantを取得
    if post.image.attached?
      case size
      when :thumbnail
        webp_image = post.thumbnail_image_webp
        fallback_image = post.thumbnail_image
      when :medium, :large
        webp_image = post.medium_image_webp
        fallback_image = post.medium_image
      end

      # Active Storage画像でWebPと通常版が両方取得できた場合：picture要素
      if webp_image.present? && fallback_image.present?
        content_tag(:picture) do
          tag.source(srcset: url_for(webp_image), type: "image/webp") +
          image_tag(fallback_image, alt: alt_text, class: css_class)
        end
      elsif fallback_image.present?
        # WebP生成に失敗した場合は通常版のみ
        image_tag(fallback_image, alt: alt_text, class: css_class)
      end
    else
      # Active Storage画像がない場合：外部URL画像またはプレースホルダー
      fallback_image = post.display_image(size, false)

      if fallback_image.present?
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
  end

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

  # WebP対応ブラウザかどうかを判定
  def supports_webp?
    return false if request.blank?

    accept_header = request.headers["HTTP_ACCEPT"] || ""
    accept_header.include?("image/webp")
  end
end