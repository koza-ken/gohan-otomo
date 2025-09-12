require 'rails_helper'

RSpec.describe "Profiles", type: :system do
  let(:user) { create(:user, :with_profile) }
  let(:private_user) { create(:user, :with_private_profile) }
  let(:other_user) { create(:user, :with_profile) }

  before do
    driven_by(:rack_test)
  end

  describe "プロフィール表示機能" do
    context "認証されていない場合" do
      it "ログインページにリダイレクトする" do
        visit user_profile_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "認証されている場合" do
      before { sign_in user }

      it "自分のプロフィールを正常に表示できる" do
        visit user_profile_path(user)

        expect(page).to have_content(user.display_name)
        expect(page).to have_content(user.favorite_foods)
        expect(page).to have_content(user.disliked_foods)
        # email表示は現在コメントアウトされているため削除
        expect(page).to have_link("プロフィールを編集")
      end

      it "他人の公開プロフィールを表示できる" do
        visit user_profile_path(other_user)

        expect(page).to have_content(other_user.display_name)
        expect(page).to have_content(other_user.favorite_foods)
        expect(page).not_to have_content(other_user.email) # 他人には非表示
        expect(page).not_to have_link("プロフィールを編集")
      end

      it "他人の非公開プロフィールにアクセスできない" do
        visit user_profile_path(private_user)

        expect(page).to have_current_path("/")
        expect(page).to have_content("このプロフィールは非公開です")
      end
    end
  end

  describe "プロフィール編集機能" do
    before { sign_in user }

    it "プロフィールを正常に編集できる" do
      visit edit_user_profile_path(user)

      expect(page).to have_content("プロフィール編集")
      expect(page).to have_field("user_display_name", with: user.display_name)
      expect(page).to have_field("user_favorite_foods", with: user.favorite_foods)
      expect(page).to have_field("user_disliked_foods", with: user.disliked_foods)

      # フォームを更新
      fill_in "user_display_name", with: "更新されたユーザー名"
      fill_in "user_favorite_foods", with: "寿司、刺身、天ぷら"
      fill_in "user_disliked_foods", with: "苦い野菜"
      # profile_public checkboxは現在コメントアウトされているため削除

      click_button "プロフィールを更新"

      expect(page).to have_current_path(user_profile_path(user))
      expect(page).to have_content("プロフィールを更新しました")
      expect(page).to have_content("更新されたユーザー名")
      expect(page).to have_content("寿司、刺身、天ぷら")
      expect(page).to have_content("苦い野菜")
    end

    it "バリデーションエラーが表示される" do
      visit edit_user_profile_path(user)

      # 長すぎる値を入力
      fill_in "user_display_name", with: "a" * 21
      fill_in "user_favorite_foods", with: "a" * 201

      click_button "プロフィールを更新"

      expect(page).to have_content("入力内容を確認してください")
      expect(page).to have_content("好きな食べ物 は200文字以内で入力してください")
    end

    it "他人のプロフィール編集にアクセスできない" do
      visit edit_user_profile_path(other_user)

      expect(page).to have_current_path("/")
      expect(page).to have_content("権限がありません")
    end
  end

end
