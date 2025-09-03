require "rails_helper"

RSpec.describe "ウェルカムアニメーション", type: :system do
  describe "初回アクセス時の動作" do
    it "ウェルカムアニメーションが表示される", pending: "アニメーション実装完了後にテスト追加" do
      visit root_path
      
      expect(current_path).to eq(welcome_path)
      expect(page).to have_selector(".welcome-container")
      expect(page).to have_content("ご飯のお供")
    end

    it "スキップボタンが表示される", pending: "アニメーション実装完了後にテスト追加" do
      visit welcome_path
      
      expect(page).to have_button("始める")
    end
  end

  describe "スキップ機能" do
    it "スキップボタンでトップページに移動する", pending: "アニメーション実装完了後にテスト追加" do
      visit welcome_path
      
      click_button "始める"
      
      expect(current_path).to eq(root_path)
      expect(page).to have_content("投稿一覧")
    end
  end

  describe "セッション管理" do
    it "アニメーション表示後は直接トップページが表示される", pending: "アニメーション実装完了後にテスト追加" do
      # 一度welcome_animationを訪問してセッションを設定
      visit welcome_path
      
      # 再度ルートにアクセス
      visit root_path
      
      expect(current_path).to eq(root_path)
      expect(page).to have_content("投稿一覧")
      expect(page).not_to have_selector(".welcome-container")
    end
  end
end