FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:display_name) { |n| "ユーザー#{n}" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_long_display_name do
      display_name { "a" * 21 }  # バリデーションエラーを引き起こすための長い名前
    end

    trait :without_display_name do
      display_name { nil }
    end
  end
end
