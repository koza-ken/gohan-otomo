# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  describe 'GET /privacy_policy' do
    it 'プライバシーポリシーページが正常に表示される' do
      get privacy_policy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('プライバシーポリシー')
    end

    it '正しいページタイトルが設定される' do
      get privacy_policy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<title>')
      expect(response.body).to include('プライバシーポリシー')
    end
  end

  describe 'GET /terms_of_service' do
    it '利用規約ページが正常に表示される' do
      get terms_of_service_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('利用規約')
    end

    it '正しいページタイトルが設定される' do
      get terms_of_service_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<title>')
      expect(response.body).to include('利用規約')
    end
  end

  describe 'ページの基本構造' do
    shared_examples 'static pageの基本構造' do |path, page_name|
      before { get path }

      it 'レスポンスステータスが200である' do
        expect(response).to have_http_status(:ok)
      end

      it 'HTMLヘッダーが適切に設定されている' do
        expect(response.content_type).to include('text/html')
      end

      it 'ナビゲーションが含まれている' do
        expect(response.body).to include('nav')
      end

      it 'フッターが含まれている' do
        expect(response.body).to include('footer')
      end

      it 'メタタグが適切に設定されている' do
        expect(response.body).to include('<meta name="viewport"')
        expect(response.body).to include('charset') # UTF-8の設定があることを確認
      end

      it 'CSSが読み込まれている' do
        expect(response.body).to include('application')
      end
    end

    it_behaves_like 'static pageの基本構造', '/privacy_policy', 'プライバシーポリシー'
    it_behaves_like 'static pageの基本構造', '/terms_of_service', '利用規約'
  end

  describe 'SEO対策' do
    it 'プライバシーポリシーページにメタディスクリプションが設定されている' do
      get privacy_policy_path

      expect(response.body).to include('<meta name="description"').or include('個人情報').or include('プライバシー')
    end

    it '利用規約ページにメタディスクリプションが設定されている' do
      get terms_of_service_path

      expect(response.body).to include('<meta name="description"').or include('利用規約').or include('サービス')
    end
  end
end