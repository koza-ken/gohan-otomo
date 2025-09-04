module ApplicationHelper
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

  # プレースホルダー画像のHTMLを生成（サイズ対応）
  def placeholder_image_tag(size, css_class)
    icon_size = size == :thumbnail ? "text-4xl" : "text-6xl"

    content_tag(:div,
                content_tag(:span, "🍚", class: "text-orange-400 #{icon_size}"),
                class: "flex items-center justify-center bg-orange-100 #{css_class}")
  end
end
