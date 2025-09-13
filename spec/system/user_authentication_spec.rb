require "rails_helper"

RSpec.describe "ユーザー認証", type: :system do
  describe "新規ユーザー登録" do
    it "有効な情報でアカウントを作成できる" do
      visit new_user_registration_path

      fill_in "表示名", with: "テストユーザー"
      fill_in "メールアドレス", with: "test@example.com"
      fill_in "パスワード", with: "password123"
      fill_in "パスワード確認", with: "password123"

      expect {
        click_button "新規登録"
      }.to change(User, :count).by(1)

      expect(page).to have_content("アカウント登録が完了しました")
      expect(User.last.display_name).to eq("テストユーザー")
    end

    it "無効な情報では登録に失敗する" do
      visit new_user_registration_path

      fill_in "表示名", with: ""
      fill_in "メールアドレス", with: "invalid_email"
      fill_in "パスワード", with: "123"
      fill_in "パスワード確認", with: "456"

      click_button "新規登録"

      expect(page).to have_content("表示名を入力してください")
      expect(page).to have_content("メールアドレスの形式が正しくありません")
      expect(page).to have_content("パスワードは6文字以上で入力してください")
      expect(page).to have_content("パスワードと確認用パスワードが一致しません")
    end

    it "表示名の重複では登録に失敗する" do
      create(:user, display_name: "既存ユーザー")

      visit new_user_registration_path

      fill_in "表示名", with: "既存ユーザー"
      fill_in "メールアドレス", with: "new@example.com"
      fill_in "パスワード", with: "password123"
      fill_in "パスワード確認", with: "password123"

      click_button "新規登録"

      expect(page).to have_content("表示名 はすでに存在します")
    end
  end

  describe "ユーザーログイン" do
    let(:user) { create(:user, email: "test@example.com", display_name: "テストユーザー") }

    it "有効な認証情報でログインできる" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "password123"
      click_button "ログイン"

      expect(page).to have_content("ログインしました")
    end
  end
end
