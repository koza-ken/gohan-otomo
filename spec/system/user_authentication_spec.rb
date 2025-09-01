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

      expect(page).to have_content("Welcome! You have signed up successfully.")
      expect(User.last.display_name).to eq("テストユーザー")
    end

    it "無効な情報では登録に失敗する" do
      visit new_user_registration_path

      fill_in "表示名", with: ""
      fill_in "メールアドレス", with: "invalid_email"
      fill_in "パスワード", with: "123"
      fill_in "パスワード確認", with: "456"

      click_button "新規登録"

      expect(page).to have_content("Display name can't be blank")
      expect(page).to have_content("Email is invalid")
      expect(page).to have_content("Password is too short")
      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    it "表示名の重複では登録に失敗する" do
      create(:user, display_name: "既存ユーザー")

      visit new_user_registration_path

      fill_in "表示名", with: "既存ユーザー"
      fill_in "メールアドレス", with: "new@example.com"
      fill_in "パスワード", with: "password123"
      fill_in "パスワード確認", with: "password123"

      click_button "新規登録"

      expect(page).to have_content("Display name has already been taken")
    end
  end

  describe "ユーザーログイン" do
    let(:user) { create(:user, email: "test@example.com", display_name: "テストユーザー") }

    it "有効な認証情報でログインできる" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "password123"
      click_button "ログイン"

      expect(page).to have_content("Signed in successfully.")
    end
  end
end
