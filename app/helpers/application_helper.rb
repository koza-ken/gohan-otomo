module ApplicationHelper
  include ImageHelper
  include SocialHelper

  # アイコン表示ヘルパーメソッド
  def icon_tag(icon_name, options = {})
    css_class = options[:class] || "w-5 h-5"
    alt_text = options[:alt] || icon_name.to_s

    # SVGファイルとして表示
    image_tag("/icons/#{icon_name}.svg",
              alt: alt_text,
              class: css_class)
  end
end
