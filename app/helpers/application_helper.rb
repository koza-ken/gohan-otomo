module ApplicationHelper
  # 投稿画像を表示するヘルパーメソッド（シンプル版）
  # まずは基本的な機能から実装
  def post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ''
    alt_text = options[:alt] || post.title
    size = options[:size] || :medium  # 新しくsizeオプションを追加
    
    # Modelのdisplay_imageメソッドに優先順位制御を委譲
    image_source = post.display_image(size)
    
    if image_source.present?
      # 画像が存在する場合（Active Storage variant または 外部URL）
      image_tag(image_source, alt: alt_text, class: css_class)
    else
      # プレースホルダーを表示
      content_tag(:div, 
                  content_tag(:span, '🍚', class: 'text-orange-400 text-4xl'),
                  class: "flex items-center justify-center h-48 bg-orange-100 #{css_class}")
    end
  end
end
