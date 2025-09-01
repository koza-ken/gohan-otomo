require "rails_helper"

RSpec.feature "ユーザー認証", type: :feature do
  scenario "新規ユーザーがアカウントを作成できる" do
    visit new_user_registration_path

    fill_in "Display name", with: "テストユーザー"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    expect {
      click_button "Sign up"
    }.to change(User, :count).by(1)

    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(User.last.display_name).to eq("テストユーザー")
  end

  scenario "既存ユーザーがログインできる" do
    user = create(:user, email: "test@example.com", display_name: "テストユーザー")

    visit new_user_session_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_content("Signed in successfully.")
  end

  scenario "無効な情報での登録に失敗する" do
    visit new_user_registration_path

    fill_in "Display name", with: ""
    fill_in "Email", with: "invalid_email"
    fill_in "Password", with: "123"
    fill_in "Password confirmation", with: "456"

    click_button "Sign up"

    expect(page).to have_content("Display name can't be blank")
    expect(page).to have_content("Email is invalid")
    expect(page).to have_content("Password is too short")
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario "表示名の重複登録に失敗する" do
    create(:user, display_name: "既存ユーザー")

    visit new_user_registration_path

    fill_in "Display name", with: "既存ユーザー"
    fill_in "Email", with: "new@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    expect(page).to have_content("Display name has already been taken")
  end
end
