# ご飯のお供アプリ テストデータ生成
# このファイルはidempotent（何度実行しても同じ結果）になるよう設計

# 本番環境ではseed実行をスキップ
if Rails.env.production?
  puts "🚫 本番環境ではテストデータを生成しません"
  return
end

puts "🍚 テストデータの生成開始..."

# 既存データがある場合は削除して再生成（開発環境のみ）
if Rails.env.development?
  puts "📝 既存データを削除中..."
  Comment.destroy_all
  Post.destroy_all
  User.destroy_all
  
  # IDシーケンスをリセット
  ActiveRecord::Base.connection.reset_pk_sequence!('users')
  ActiveRecord::Base.connection.reset_pk_sequence!('posts')
  ActiveRecord::Base.connection.reset_pk_sequence!('comments')
end

# テストユーザーの作成
puts "👥 テストユーザーを作成中..."

test_users = [
  {
    email: "rice_lover@example.com",
    password: "password123",
    display_name: "お米大好きさん",
    favorite_foods: "白ご飯、おにぎり、炊き込みご飯",
    disliked_foods: "パン",
    profile_public: true
  },
  {
    email: "cooking_master@example.com", 
    password: "password123",
    display_name: "料理の達人",
    favorite_foods: "和食全般、魚料理",
    disliked_foods: "辛い物",
    profile_public: true
  },
  {
    email: "gourmet_hunter@example.com",
    password: "password123", 
    display_name: "グルメハンター",
    favorite_foods: "地方の特産品、珍味",
    disliked_foods: "化学調味料",
    profile_public: true
  },
  {
    email: "homecook@example.com",
    password: "password123",
    display_name: "家庭料理人",
    favorite_foods: "手作り料理、懐かしい味",
    disliked_foods: "冷凍食品",
    profile_public: false
  },
  {
    email: "student_chef@example.com",
    password: "password123",
    display_name: "料理学生",
    favorite_foods: "簡単レシピ、節約料理",
    disliked_foods: "高級食材",
    profile_public: true
  }
]

users = test_users.map do |user_data|
  User.create!(user_data)
end

puts "✅ #{users.count}人のテストユーザーを作成しました"

# ご飯のお供データ（ページネーションテスト用に30件以上）
puts "🍚 ご飯のお供投稿を作成中..."

gohan_otomo_data = [
  # 定番のご飯のお供
  { title: "明太子", description: "プチプチした食感と辛味が最高！九州福岡の名産品です。", link: "https://example.com/mentaiko", image_url: "" },
  { title: "いくら醤油漬け", description: "贅沢なプチプチ食感。特別な日のご飯に最適です。", link: "https://example.com/ikura", image_url: "" },
  { title: "鮭フレーク", description: "手軽で美味しい定番のご飯のお供。おにぎりにも最適。", link: "https://example.com/sake-flake", image_url: "" },
  { title: "のり佃煮", description: "甘辛い味付けがご飯とベストマッチ。朝食の定番です。", link: "https://example.com/nori-tsukudani", image_url: "" },
  { title: "梅干し", description: "日本の伝統的な保存食。塩分補給にも良いです。", link: "https://example.com/umeboshi", image_url: "" },
  
  # 地域特産品
  { title: "博多明太子", description: "本場福岡の辛子明太子。一度食べたら忘れられません。", link: "https://example.com/hakata-mentaiko" },
  { title: "北海道いくら", description: "新鮮な秋鮭の卵を使った贅沢な一品。", link: "https://example.com/hokkaido-ikura" },
  { title: "京都のちりめん山椒", description: "上品な山椒の香りが効いた関西の味。", link: "https://example.com/chirimen-sansho" },
  { title: "信州味噌", description: "コクのある味噌でご飯が進みます。", link: "https://example.com/shinshu-miso" },
  { title: "沖縄の島らっきょう", description: "ピリッとした辛みと独特の食感が癖になる。", link: "https://example.com/shima-rakkyo" },
  
  # 珍しい・創作系
  { title: "アボカド醤油", description: "意外な組み合わせですが、とろけるような美味しさ。", link: "https://example.com/avocado-shoyu" },
  { title: "塩昆布チーズ", description: "塩昆布の旨味とチーズのコクが絶妙にマッチ。", link: "https://example.com/shiokombu-cheese" },
  { title: "キムチ納豆", description: "発酵食品同士の相性抜群。健康にも良いです。", link: "https://example.com/kimchi-natto" },
  { title: "バター醤油海苔", description: "洋風テイストの新しいご飯のお供。", link: "https://example.com/butter-shoyu-nori" },
  { title: "ツナマヨコーン", description: "子どもも大好きな優しい味。おにぎりの具材としても人気。", link: "https://example.com/tuna-mayo-corn" },
  
  # 手作り系
  { title: "自家製なめたけ", description: "えのきだけで簡単に作れる手作りの味。", link: "https://example.com/homemade-nametake" },
  { title: "手作り塩辛", description: "新鮮なイカで作る本格的な塩辛。日本酒にも合います。", link: "https://example.com/homemade-shiokara" },
  { title: "おかかチーズ", description: "かつお節とチーズの意外な組み合わせ。", link: "https://example.com/okaka-cheese" },
  { title: "手作りラー油", description: "香辛料たっぷりの自家製ラー油でご飯が進む。", link: "https://example.com/homemade-rayu" },
  { title: "ごま油塩", description: "シンプルだけど奥深い味。ごま油の香りが食欲をそそります。", link: "https://example.com/goma-abura-shio" },
  
  # 季節の味
  { title: "筋子醤油漬け", description: "秋の味覚。いくらより手頃で美味しい。", link: "https://example.com/sujiko" },
  { title: "新生姜の佃煮", description: "初夏の香り豊かな新生姜を甘辛く煮詰めて。", link: "https://example.com/shin-shoga-tsukudani" },
  { title: "山菜の塩漬け", description: "春の山菜を塩で漬けた自然の恵み。", link: "https://example.com/sansai-shiozuke" },
  { title: "柚子胡椒", description: "爽やかな柚子の香りと青唐辛子の辛み。九州の調味料。", link: "https://example.com/yuzu-kosho" },
  { title: "紅葉おろし", description: "大根おろしに唐辛子を混ぜた、見た目も美しい薬味。", link: "https://example.com/momiji-oroshi" },
  
  # 健康志向
  { title: "黒胡麻ふりかけ", description: "栄養豊富な黒ごまをたっぷり使ったヘルシーなふりかけ。", link: "https://example.com/kuro-goma-furikake" },
  { title: "ひじきの煮物", description: "ミネラル豊富なひじきを使った和の惣菜。", link: "https://example.com/hijiki-nimono" },
  { title: "納豆昆布", description: "納豆と昆布の相乗効果で健康パワーアップ。", link: "https://example.com/natto-kombu" },
  { title: "しらす干し", description: "カルシウムたっぷりの小魚。ご飯にそのままかけて。", link: "https://example.com/shirasu-boshi" },
  { title: "わかめご飯の素", description: "海の恵みたっぷり。ミネラル補給に最適。", link: "https://example.com/wakame-gohan" },
  
  # 贅沢系
  { title: "うに醤油漬け", description: "北海道産の新鮮なうにを贅沢に使用。特別な日に。", link: "https://example.com/uni-shoyu" },
  { title: "からすみ", description: "日本三大珍味のひとつ。濃厚な旨味が特徴。", link: "https://example.com/karasumi" },
  { title: "このわた", description: "なまこの腸を塩辛にした珍味中の珍味。", link: "https://example.com/konowata" },
  { title: "高級いくら", description: "粒の大きな最高級品質のいくら。口の中でとろける。", link: "https://example.com/premium-ikura" },
  { title: "トリュフ塩", description: "世界三大珍味のトリュフを使った贅沢な塩。", link: "https://example.com/truffle-salt" }
]

created_posts = []
gohan_otomo_data.each_with_index do |post_data, index|
  user = users[index % users.count]
  post = Post.create!(
    title: post_data[:title],
    description: post_data[:description],
    link: post_data[:link],
    image_url: post_data[:image_url],
    user: user,
    created_at: rand(30.days).seconds.ago # 過去30日間のランダムな日時
  )
  created_posts << post
end

puts "✅ #{created_posts.count}件のご飯のお供投稿を作成しました"

# コメント投稿（各投稿に1-3件のランダムなコメント）
puts "💬 コメントを作成中..."

comment_templates = [
  "これ本当に美味しいですよね！",
  "今度試してみます！",
  "うちでも作ってみました。最高でした！",
  "どこで買えますか？",
  "レシピを教えてください！",
  "子どもも喜んで食べてました。",
  "ご飯が何杯でも食べられそう。",
  "初めて知りました。面白そうですね！",
  "これを知ってから毎日食べてます。",
  "地元の味ですね。懐かしいです。",
  "健康にも良さそうで一石二鳥ですね。",
  "見た目も美しくて食欲をそそります。",
  "意外な組み合わせですが美味しそう！",
  "季節限定なんですね。貴重な情報ありがとうございます。",
  "手作りだと愛情も込められて良いですね。"
]

total_comments = 0
created_posts.each do |post|
  comment_count = rand(0..3) # 各投稿に0-3件のコメント
  comment_count.times do
    commenting_user = users[rand(users.count)]
    # 自分の投稿にはコメントしない
    next if commenting_user == post.user
    
    Comment.create!(
      content: comment_templates[rand(comment_templates.count)],
      user: commenting_user,
      post: post,
      created_at: rand((post.created_at)..(Time.current)) # 投稿日時以降のランダムな日時
    )
    total_comments += 1
  end
end

puts "✅ #{total_comments}件のコメントを作成しました"

puts <<~SUMMARY

🎉 テストデータの生成完了！

📊 作成されたデータ:
  👥 ユーザー: #{users.count}人
  🍚 投稿: #{created_posts.count}件
  💬 コメント: #{total_comments}件

🔐 テストユーザーのログイン情報:
  📧 Email: rice_lover@example.com
  🔑 Password: password123

🚀 ページネーション機能テストに十分なデータ量です！
   (1ページ8件 × 約4ページ分のデータ)

SUMMARY
