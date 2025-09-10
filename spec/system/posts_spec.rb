
require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  before do
    driven_by(:rack_test)
    # セッションでアニメーション表示済みに設定
    allow_any_instance_of(PostsController).to receive(:session).and_return({ welcome_shown: true })
    # System specでは日本語ロケールを使用
    I18n.locale = :ja
  end

  describe "投稿一覧画面" do
    context "投稿一覧表示" do

      let!(:posts) { create_list(:post, 3) }

      it "投稿一覧が表示される" do
        visit posts_path
        expect(page).to have_content("🍚 みんなのお供")

        posts.each do |post|
          expect(page).to have_content(post.title)
          expect(page).to have_content(post.description)
          expect(page).to have_content(post.user.display_name)
        end
      end

      it "投稿詳細にアクセスできる" do
        visit posts_path
        click_link posts.first.title

        expect(current_path).to eq(post_path(posts.first))
        expect(page).to have_content(posts.first.title)
        expect(page).to have_content(posts.first.description)
      end
    end

    context "特定ユーザーの投稿一覧" do

      let!(:user_posts) { create_list(:post, 2, user: user) }
      let!(:other_post) { create(:post, user: other_user) }

      it "指定ユーザーの投稿のみ表示される" do
        visit posts_path(user_id: user.id)

        expect(page).to have_content("#{user.display_name}さんの投稿")

        user_posts.each do |post|
          expect(page).to have_content(post.title)
        end

        expect(page).not_to have_content(other_post.title)
      end
    end
  end

  describe "投稿詳細画面" do

    it "投稿詳細が正しく表示される" do
      visit post_path(post_record)

      expect(page).to have_content(post_record.title)
      expect(page).to have_content(post_record.description)
      expect(page).to have_content(post_record.user.display_name)
    end

    it "コメントが表示される" do
      comment = create(:comment, post: post_record, content: "とても美味しそうです！")

      visit post_path(post_record)

      expect(page).to have_content(comment.content)
      expect(page).to have_content(comment.user.display_name)
    end
  end

  describe "投稿作成機能" do
    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "新規投稿ができる" do
        visit new_post_path

        fill_in "商品名", with: "テスト商品"
        fill_in "おすすめポイント", with: "とても美味しいです"
        fill_in "通販リンク", with: "https://example.com/product"
        fill_in "画像URL", with: "https://example.com/image.jpg"

        expect {
          click_button "投稿する"
        }.to change(Post, :count).by(1)

        expect(current_path).to eq(post_path(Post.last))
        expect(page).to have_content("投稿が作成されました")
        expect(page).to have_content("テスト商品")
        expect(page).to have_content("とても美味しいです")
      end

      it "バリデーションエラーが表示される" do
        visit new_post_path

        fill_in "商品名", with: ""
        fill_in "おすすめポイント", with: ""

        click_button "投稿する"

        expect(page).to have_content("商品名 を入力してください")
        expect(page).to have_content("おすすめポイント を入力してください")
        expect(Post.count).to eq(0)
      end
    end

    context "ログインしていない場合" do

      it "ログインページにリダイレクトされる" do
        visit new_post_path
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  describe "投稿編集機能" do
    context "投稿者がアクセスする場合" do
      before do
        sign_in user
      end

      it "投稿を編集できる" do
        visit edit_post_path(post_record)

        fill_in "商品名", with: "更新されたタイトル"
        fill_in "おすすめポイント", with: "更新された説明"

        click_button "更新する"

        expect(current_path).to eq(post_path(post_record))
        expect(page).to have_content("投稿が更新されました")
        expect(page).to have_content("更新されたタイトル")
        expect(page).to have_content("更新された説明")
      end

      it "バリデーションエラーが表示される" do
        visit edit_post_path(post_record)

        fill_in "商品名", with: ""

        click_button "更新する"

        expect(page).to have_content("商品名 を入力してください")
      end
    end

    context "投稿者以外がアクセスする場合" do
      before do
        sign_in other_user
      end

      it "投稿一覧にリダイレクトされる" do
        visit edit_post_path(post_record)
        expect(current_path).to eq(posts_path)
        expect(page).to have_content("この操作は許可されていません")
      end
    end
  end

  describe "投稿削除機能" do
    context "投稿者が削除する場合" do
      before do
        sign_in user
      end

      it "投稿を削除できる" do
        visit post_path(post_record)

        expect {
          click_link "削除"
        }.to change(Post, :count).by(-1)

        expect(current_path).to eq(posts_path)
        expect(page).to have_content("投稿が削除されました")
      end
    end

    context "投稿者以外が削除しようとする場合" do
      before do
        sign_in other_user
      end

      it "削除リンクが表示されない" do
        visit post_path(post_record)
        expect(page).not_to have_link("削除")
      end
    end
  end

  describe "ナビゲーション機能" do

    context "ログインしていない場合" do
      it "適切なナビゲーションが表示される" do
        visit posts_path

        expect(page).to have_link("ログイン")
        expect(page).not_to have_link("新しいお供を投稿")
        expect(page).not_to have_link("ログアウト")
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "適切なナビゲーションが表示される" do
        visit posts_path

        expect(page).to have_link("新しいお供を投稿")
        expect(page).to have_link("マイ投稿一覧")
        expect(page).to have_link("プロフィールを見る")
        expect(page).to have_button("ログアウト")
        expect(page).not_to have_link("ログイン")
      end

      it "マイ投稿リンクから自分の投稿一覧に移動できる" do
        create_list(:post, 2, user: user)

        visit posts_path
        click_link "マイ投稿一覧"

        expect(current_path).to eq(posts_path)
        expect(page).to have_content("#{user.display_name}さんの投稿")
      end
    end
  end

  describe "投稿者名リンク機能" do

    it "投稿者名をクリックするとその投稿者の投稿一覧に移動する" do
      create_list(:post, 2, user: user)

      visit posts_path
      first(:link, user.display_name).click

      expect(current_path).to eq(posts_path)
      expect(page).to have_content("#{user.display_name}さんの投稿")
    end
  end

  describe "画像アップロード機能" do
    before do
      sign_in user
    end

    context "新規投稿での基本機能" do
      it "画像ファイルをアップロードして投稿できる" do
        visit new_post_path

        fill_in "商品名", with: "画像付きテスト商品"
        fill_in "おすすめポイント", with: "美味しそうな見た目です"
        
        # 画像ファイルをアップロード
        attach_file "画像をアップロード（任意）", Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')

        expect {
          click_button "投稿する"
        }.to change(Post, :count).by(1)

        post = Post.last
        expect(post.image.attached?).to be true
        expect(post.image.filename.to_s).to eq('test_image.jpg')
        
        expect(current_path).to eq(post_path(post))
        expect(page).to have_content("投稿が作成されました")
        expect(page).to have_content("画像付きテスト商品")
      end

      it "画像URLのみで投稿できる" do
        visit new_post_path

        fill_in "商品名", with: "URL画像テスト"
        fill_in "おすすめポイント", with: "外部画像のテスト"
        fill_in "画像URL", with: "https://example.com/external.jpg"

        click_button "投稿する"

        post = Post.last
        expect(post.image_url).to eq("https://example.com/external.jpg")
        expect(post.has_image?).to be true
        
        expect(current_path).to eq(post_path(post))
        expect(page).to have_content("投稿が作成されました")
      end
    end

    context "画像の基本確認" do
      it "画像URLのみの投稿で適切に表示される" do
        post_with_url = create(:post, :with_image, user: user)
        
        visit post_path(post_with_url)
        
        expect(page).to have_content(post_with_url.title)
        expect(post_with_url.has_image?).to be true
      end

      it "画像がない投稿でも正常に表示される" do
        post_without_image = create(:post, user: user)
        
        visit post_path(post_without_image)
        
        expect(page).to have_content(post_without_image.title)
        expect(post_without_image.has_image?).to be false
      end
    end
  end
end
