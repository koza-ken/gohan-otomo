require 'rails_helper'

RSpec.describe "いいね機能", type: :system do
  before do
    driven_by(:rack_test)
  end

  context "投稿詳細ページでのいいね操作" do
    context "ログイン済みユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
      
      before do
        sign_in user2
        visit post_path(post_record)
      end

      it "いいねボタンが表示される" do
        expect(page).to have_selector('turbo-frame') # turbo-frameタグの存在確認
        expect(page).to have_content("0") # 初期いいね数
      end

    end

    context "未ログインユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
      
      before do
        visit post_path(post_record)
      end

      it "いいねボタンは表示されるがクリックできない状態" do
        # 期待するセレクタ
        expected_selector = '[data-turbo-frame="like_button_' + post_record.id.to_s + '"]'
        
        # デバッグ出力
        puts "Looking for selector: #{expected_selector}"
        puts "Page content: #{page.body}" if ENV['DEBUG']
        
        expect(page).to have_selector('turbo-frame') # turbo-frameタグの存在確認
        expect(page).to have_content("0") # いいね数は表示される
        
        # リンクが存在しないことを確認（クリックできない）
        expect(page).not_to have_css('turbo-frame a')
      end
    end
  end

  context "投稿一覧ページでのいいね操作" do
    context "ログイン済みユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
      
      before do
        sign_in user2
        visit posts_path
      end

      it "いいねボタンが投稿カードに表示される" do
        expect(page).to have_selector('turbo-frame') # turbo-frameタグの存在確認
        expect(page).to have_content("0") # 初期いいね数
      end

    end

    context "未ログインユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
      
      before do
        visit posts_path
      end

      it "いいね数は表示されるがボタンは無効化されている" do
        expect(page).to have_selector('turbo-frame') # turbo-frameタグの存在確認  
        expect(page).to have_content("0")
        expect(page).to have_css('.text-gray-400') # 無効化されたスタイル
      end
    end
  end

  context "複数ユーザーのいいね動作" do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
    let!(:post2) { create(:post, title: "投稿2", user: user) }
    
    before do
      sign_in user2
    end


    it "他のユーザーのいいねと混在して正しく表示される" do
      # user が post_record にいいね
      create(:like, user: user, post: post_record)
      
      visit post_path(post_record)
      
      # 他のユーザーのいいねがカウントされている
      expect(page).to have_content("1")
      
      # user2はまだいいねしていない状態のボタン
      expect(page).to have_css('.bg-gray-100')
    end
  end

  context "いいね数の表示" do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:post_record) { create(:post, title: "テスト投稿", description: "テスト投稿の説明", user: user) }
    
    it "いいね数が正確に表示される" do
      # 3人のユーザーがいいね
      user3 = create(:user)
      create(:like, user: user, post: post_record)
      create(:like, user: user2, post: post_record)
      create(:like, user: user3, post: post_record)
      
      visit post_path(post_record)
      expect(page).to have_content("3")
      
      visit posts_path
      expect(page).to have_content("3")
    end
  end
end