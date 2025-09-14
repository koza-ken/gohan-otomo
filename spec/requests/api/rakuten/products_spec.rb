# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Rakuten::Products', type: :request do
  let(:user) { create(:user) }

  describe 'POST /api/rakuten/search_products' do
    before { sign_in user }

    context '正常なリクエストの場合' do
      let(:mock_products) do
        [
          {
            title: '美味しいお米 5kg',
            description: 'とても美味しいお米です',
            image_url: 'https://thumbnail.image.rakuten.co.jp/test.jpg',
            price: 2980,
            rakuten_url: 'https://item.rakuten.co.jp/test-shop/test-item/',
            shop_name: 'テストショップ'
          }
        ]
      end

      before do
        allow(RakutenProductService).to receive(:fetch_product_candidates)
          .with('お米', limit: 12)
          .and_return(mock_products)
      end

      it '商品検索結果をJSONで返す' do
        post '/api/rakuten/search_products', params: { q: 'お米' }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response['products']).to be_an(Array)
        expect(json_response['products'].size).to eq(1)

        product = json_response['products'].first
        expect(product['title']).to eq('美味しいお米 5kg')
        expect(product['description']).to eq('とても美味しいお米です')
        expect(product['image_url']).to eq('https://thumbnail.image.rakuten.co.jp/test.jpg')
        expect(product['price']).to eq(2980)
        expect(product['rakuten_url']).to eq('https://item.rakuten.co.jp/test-shop/test-item/')
        expect(product['shop_name']).to eq('テストショップ')
      end
    end

    context '検索キーワードが空の場合' do
      it '空の商品配列を返す' do
        get '/api/rakuten/products/search', params: { q: '' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products']).to eq([])
      end
    end

    context 'qパラメータがない場合' do
      it '空の商品配列を返す' do
        get '/api/rakuten/products/search'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products']).to eq([])
      end
    end

    context 'サービスでエラーが発生する場合' do
      before do
        allow(RakutenProductService).to receive(:fetch_product_candidates)
          .and_raise(StandardError, 'Service Error')
      end

      it 'エラーレスポンスを返す' do
        get '/api/rakuten/products/search', params: { q: 'お米' }

        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'GET /api/rakuten/products/proxy_image' do
    before { sign_in user }

    context '許可された楽天画像URLの場合' do
      let(:rakuten_image_url) { 'https://thumbnail.image.rakuten.co.jp/test.jpg' }
      let(:mock_image_data) { 'fake image data' }

      before do
        # HTTPリクエストのモック
        http_mock = double('Net::HTTP')
        request_mock = double('Net::HTTP::Get')
        response_mock = double('Net::HTTPResponse')

        allow(Net::HTTP).to receive(:new).and_return(http_mock)
        allow(Net::HTTP::Get).to receive(:new).and_return(request_mock)
        allow(http_mock).to receive(:request).and_return(response_mock)
        allow(response_mock).to receive(:body).and_return(mock_image_data)
        allow(response_mock).to receive(:content_type).and_return('image/jpeg')

        # URI.parseのモック
        uri_mock = double('URI')
        allow(URI).to receive(:parse).and_return(uri_mock)
        allow(uri_mock).to receive(:host).and_return('thumbnail.image.rakuten.co.jp')
        allow(uri_mock).to receive(:port).and_return(443)
        allow(uri_mock).to receive(:path).and_return('/test.jpg')
        allow(uri_mock).to receive(:query).and_return(nil)
      end

      it 'プロキシ経由で画像データを返す' do
        get '/api/rakuten/products/proxy_image', params: { image_url: rakuten_image_url }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('image/jpeg')
        expect(response.body).to eq(mock_image_data)
      end
    end

    context '許可されていないドメインの場合' do
      let(:invalid_image_url) { 'https://example.com/malicious.jpg' }

      it 'アクセスを拒否する' do
        get '/api/rakuten/products/proxy_image', params: { image_url: invalid_image_url }

        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('許可されていない画像URLです')
      end
    end

    context 'image_urlパラメータがない場合' do
      it 'バッドリクエストエラーを返す' do
        get '/api/rakuten/products/proxy_image'

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('画像URLが指定されていません')
      end
    end
  end

  describe '認証が必要' do
    context 'ログインしていない場合' do
      it 'search APIでリダイレクトされる' do
        get '/api/rakuten/products/search', params: { q: 'お米' }
        expect(response).to have_http_status(:found) # リダイレクト
      end

      it 'proxy_image APIでリダイレクトされる' do
        get '/api/rakuten/products/proxy_image', params: { image_url: 'https://test.com' }
        expect(response).to have_http_status(:found) # リダイレクト
      end
    end
  end
end