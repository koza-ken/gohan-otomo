FactoryBot.define do
  factory :post do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    link { "MyString" }
    image_url { "MyString" }
  end
end
