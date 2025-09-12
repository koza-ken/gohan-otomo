# frozen_string_literal: true

# Rakuten Web Service API Configuration
# 楽天APIクライアントの設定
# rails起動時にcredentialファイルからAPI IDを取得してくれる
RakutenWebService.configure do |c|
  # テスト環境や認証情報未設定時の安全な処理
  rakuten_config = Rails.application.credentials.rakuten || {}
  
  c.application_id = rakuten_config[:application_id] || 'dummy_application_id_for_test'
  
  # アフィリエイトIDがある場合は以下を有効化
  # c.affiliate_id = rakuten_config[:affiliate_id]
end
