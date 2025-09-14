# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RakutenProductService, type: :service do
  describe '.fetch_product_candidates' do
    context '正常な検索の場合' do
      let(:mock_item) do
        double(
          'RakutenItem',
          name: '美味しいお米 5kg',
          caption: '<p>とても美味しいお米です。</p><br>栄養満点！',
          price: 2980,
          url: 'https://item.rakuten.co.jp/test-shop/test-item/',
          shop_name: 'テストショップ',
          medium_image_urls: ['https://thumbnail.image.rakuten.co.jp/test.jpg_ex=128x128'],
          small_image_urls: ['https://thumbnail.image.rakuten.co.jp/small.jpg'],
          image_url: 'https://thumbnail.image.rakuten.co.jp/default.jpg'
        )
      end

      before do
        allow(RakutenWebService::Ichiba::Item).to receive(:search)
          .with(keyword: 'お米', hits: 12)
          .and_return([mock_item])
      end

      it '商品候補を正常に取得できる' do
        result = described_class.fetch_product_candidates('お米')

        expect(result).to be_an(Array)
        expect(result.size).to eq(1)

        product = result.first
        expect(product[:title]).to eq('美味しいお米 5kg')
        expect(product[:description]).to eq('とても美味しいお米です。栄養満点！')
        expect(product[:price]).to eq(2980)
        expect(product[:rakuten_url]).to eq('https://item.rakuten.co.jp/test-shop/test-item/')
        expect(product[:shop_name]).to eq('テストショップ')
        expect(product[:image_url]).to eq('https://thumbnail.image.rakuten.co.jp/test.jpg_ex=400x400')
      end

      it '指定した件数制限で検索される' do
        expect(RakutenWebService::Ichiba::Item).to receive(:search)
          .with(keyword: 'お米', hits: 5)
          .and_return([mock_item])

        described_class.fetch_product_candidates('お米', limit: 5)
      end
    end

    context '空の検索キーワードの場合' do
      it '空の配列を返す' do
        result = described_class.fetch_product_candidates('')
        expect(result).to eq([])
      end

      it 'nilの場合も空の配列を返す' do
        result = described_class.fetch_product_candidates(nil)
        expect(result).to eq([])
      end
    end

    context 'APIエラーの場合' do
      before do
        allow(RakutenWebService::Ichiba::Item).to receive(:search)
          .and_raise(StandardError, 'API Error')
      end

      it 'エラー時は空の配列を返す' do
        result = described_class.fetch_product_candidates('お米')
        expect(result).to eq([])
      end

      it 'エラーログが出力される' do
        expect(Rails.logger).to receive(:error).with(/楽天API検索エラー/).once
        expect(Rails.logger).to receive(:error).at_least(:once)
        described_class.fetch_product_candidates('お米')
      end
    end

    context 'タイムアウトエラーの場合' do
      before do
        allow(RakutenWebService::Ichiba::Item).to receive(:search)
          .and_raise(Timeout::Error, 'Timeout')
      end

      it 'タイムアウト時は空の配列を返す' do
        result = described_class.fetch_product_candidates('お米')
        expect(result).to eq([])
      end

      it 'タイムアウトログが出力される' do
        expect(Rails.logger).to receive(:error).with(/楽天API タイムアウト/)
        described_class.fetch_product_candidates('お米')
      end
    end
  end

  describe '.format_product_info' do
    let(:mock_item) do
      double(
        'RakutenItem',
        name: 'テスト商品',
        caption: '<strong>HTML</strong>を含む説明<br>改行あり',
        price: 1500,
        url: 'https://item.rakuten.co.jp/shop/item/',
        shop_name: 'テストショップ',
        medium_image_urls: ['https://test-image.jpg'],
        small_image_urls: nil,
        image_url: nil
      )
    end

    it '商品情報を正しい形式に変換する' do
      result = described_class.send(:format_product_info, mock_item)

      expect(result[:title]).to eq('テスト商品')
      expect(result[:description]).to eq('HTMLを含む説明改行あり')
      expect(result[:price]).to eq(1500)
      expect(result[:rakuten_url]).to eq('https://item.rakuten.co.jp/shop/item/')
      expect(result[:shop_name]).to eq('テストショップ')
      expect(result[:image_url]).to eq('https://test-image.jpg')
    end
  end

  describe '.get_first_image_url' do
    context 'medium_image_urlsが存在する場合' do
      let(:item) do
        double(
          'RakutenItem',
          name: 'テスト商品',
          medium_image_urls: ['https://thumbnail.image.rakuten.co.jp/test.jpg_ex=128x128']
        )
      end

      it 'URLパラメータを400x400に変換して返す' do
        result = described_class.send(:get_first_image_url, item)
        expect(result).to eq('https://thumbnail.image.rakuten.co.jp/test.jpg_ex=400x400')
      end
    end

    context 'small_image_urlsのみ存在する場合' do
      let(:item) do
        double(
          'RakutenItem',
          name: 'テスト商品',
          medium_image_urls: nil,
          small_image_urls: ['https://thumbnail.image.rakuten.co.jp/small.jpg']
        )
      end

      before do
        allow(item).to receive(:respond_to?).with(:small_image_urls).and_return(true)
      end

      it 'small_image_urlsを返す' do
        result = described_class.send(:get_first_image_url, item)
        expect(result).to eq('https://thumbnail.image.rakuten.co.jp/small.jpg')
      end
    end

    context '画像URLが存在しない場合' do
      let(:item) do
        double(
          'RakutenItem',
          name: 'テスト商品',
          medium_image_urls: nil,
          small_image_urls: nil,
          image_url: nil
        )
      end

      before do
        allow(item).to receive(:respond_to?).with(:small_image_urls).and_return(true)
        allow(item).to receive(:respond_to?).with(:image_url).and_return(true)
      end

      it 'nilを返す' do
        result = described_class.send(:get_first_image_url, item)
        expect(result).to be_nil
      end
    end
  end

  describe '.strip_html' do
    it 'HTMLタグを除去する' do
      html = '<p>テスト<br>内容</p><strong>重要</strong>'
      result = described_class.send(:strip_html, html)
      expect(result).to eq('テスト内容重要')
    end

    it '連続した空白を単一空白に変換する' do
      html = 'テスト     内容    です'
      result = described_class.send(:strip_html, html)
      expect(result).to eq('テスト 内容 です')
    end

    it 'nilや空文字の場合はnilを返す' do
      expect(described_class.send(:strip_html, nil)).to be_nil
      expect(described_class.send(:strip_html, '')).to be_nil
      expect(described_class.send(:strip_html, '   ')).to be_nil
    end
  end
end