# frozen_string_literal: true

# Rakuten Web Service API Configuration
# 楽天APIクライアントの設定
# rails起動時にcredentialファイルからAPI IDを取得してくれる
RakutenWebService.configure do |c|
  c.application_id = Rails.application.credentials.rakuten[:application_id]
  # アフィリエイトIDがある場合は以下を有効化
  # c.affiliate_id = Rails.application.credentials.rakuten[:affiliate_id]
end
