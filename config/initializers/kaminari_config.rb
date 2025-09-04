# frozen_string_literal: true

Kaminari.configure do |config|
  # 1ページあたりのデフォルト表示件数（グリッドレイアウト3x4を想定）
  config.default_per_page = 12
  # 最大表示件数（パフォーマンス考慮）
  config.max_per_page = 50
  # ページネーションの表示窓幅（現在ページの前後に表示するページ数）
  config.window = 2
  # 両端の表示窓幅
  config.outer_window = 1
end
