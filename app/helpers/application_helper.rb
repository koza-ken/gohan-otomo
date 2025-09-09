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

  # X投稿ボタンを生成するヘルパーメソッド
  def x_share_button(post, options = {})
    # 投稿用のテキストを生成
    share_text = generate_share_text(post)
    # 投稿詳細ページのURL
    post_url = post_url(post)
    # X Web Intents APIのURL
    x_intent_url = "https://twitter.com/intent/tweet?text=#{CGI.escape(share_text)}&url=#{CGI.escape(post_url)}"

    # デフォルトのCSSクラス（お米テーマに合わせたデザイン）
    default_class = "inline-flex items-center gap-2 px-3 py-1 bg-sky-500 hover:bg-sky-600 text-white rounded-full transition-colors duration-200"
    css_class = options[:class] || default_class

    link_to(x_intent_url,
            target: "_blank",
            rel: "noopener noreferrer",
            class: css_class,
            data: { turbo: false }) do
      content_tag(:span, "𝕏", class: "text-sm font-bold") +
      content_tag(:span, "シェア", class: "text-sm")
    end
  end

  private

  # X投稿用のテキストを生成
  def generate_share_text(post)
    # シンプルでキャッチーなメッセージに変更
    base_text = "「#{post.title}」がおすすめ！！ #ご飯のお供 #gohan_otomo"
    
    # 投稿URLが含まれない場合はアプリのURLを追加
    # （X Web Intents APIで自動的にURLパラメータが追加されるため、通常は不要）
    base_text
  end
end
