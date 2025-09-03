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
  end
end
