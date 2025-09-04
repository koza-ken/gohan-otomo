FactoryBot.define do
  factory :post do
    association :user
    title { "テスト商品#{rand(1000..9999)}" }
    description { "これは美味しいご飯のお供です" }
    link { nil }  # デフォルトはnull（任意項目）
    image_url { nil }  # デフォルトはnull（任意項目）

    trait :with_link do
      link { "https://example.com/product" }
    end

    trait :with_image do
      image_url { "https://example.com/image.jpg" }
    end

    # Active Storage画像添付用のtrait
    trait :with_attached_image do
      after(:build) do |post|
        post.image.attach(
          io: StringIO.new("fake image data"),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    # 複合trait: 通販リンクと外部画像URL両方
    trait :with_link_and_image do
      with_link
      with_image
    end

    # 複合trait: Active Storage画像と通販リンク両方
    trait :with_attached_image_and_link do
      with_attached_image
      with_link
    end
  end
end
