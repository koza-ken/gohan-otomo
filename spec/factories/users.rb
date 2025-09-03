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

    # プロフィール関連のtrait
    trait :with_profile do
      favorite_foods { "白米、納豆、海苔の佃煮、明太子" }
      disliked_foods { "辛いもの、苦いもの" }
      profile_public { true }
    end

    trait :with_detailed_profile do
      favorite_foods { "白米、納豆、海苔の佃煮、明太子、しらす丼、焼き海苔、梅干し、昆布の佃煮" }
      disliked_foods { "辛いもの、苦いもの、パクチー、セロリ" }
      profile_public { true }
    end

    trait :with_private_profile do
      favorite_foods { "秘密の食べ物" }
      disliked_foods { "嫌いなものも秘密" }
      profile_public { false }
    end

    trait :without_profile_foods do
      favorite_foods { "" }
      disliked_foods { "" }
      profile_public { true }
    end

    # 投稿・コメント関連のtrait
    trait :active_poster do
      display_name { "グルメ太郎" }
      favorite_foods { "美味しいものなら何でも" }
      profile_public { true }
    end

    trait :frequent_commenter do
      display_name { "感想マン" }
      favorite_foods { "いろいろな商品を試すのが好き" }
      profile_public { true }
    end
  end
end
