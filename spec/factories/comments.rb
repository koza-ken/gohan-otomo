FactoryBot.define do
  factory :comment do
    association :user
    association :post
    content { "とても美味しかったです！ご飯が進みました。" }

    trait :short_comment do
      content { "美味しい！" }
    end

    trait :long_comment do
      content { "この商品は本当に素晴らしいです。ご飯との相性が抜群で、毎日食べても飽きません。特に朝ごはんにぴったりです。家族全員が気に入っており、リピート確定の商品だと思います。おすすめポイントは、塩加減が絶妙なところと、食感が良いところです。" }
    end

    trait :negative_comment do
      content { "期待していたほどではありませんでした。もう少し味が濃い方が好みです。" }
    end
  end
end
