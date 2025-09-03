module ApplicationHelper
  # 投稿画像を表示するヘルパーメソッド（シンプル版）
  # まずは基本的な機能から実装
  def post_image_tag(post, options = {})
    # デフォルト値の設定
    css_class = options[:class] || ''
    alt_text = options[:alt] || post.title
    
    # 1. Active Storageに画像があるかチェック
    if post.image.attached?
      # Active Storage の画像を表示
      image_tag(post.image, alt: alt_text, class: css_class)
    elsif post.image_url.present?
      # 外部URL（image_url）の画像を表示
      image_tag(post.image_url, alt: alt_text, class: css_class)
    else
      # プレースホルダーを表示
      content_tag(:div, 
                  content_tag(:span, '🍚', class: 'text-orange-400 text-4xl'),
                  class: "flex items-center justify-center h-48 bg-orange-100 #{css_class}")
    end
  end
end
