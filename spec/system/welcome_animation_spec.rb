require "rails_helper"

RSpec.describe "ウェルカムアニメーション", type: :system do
  describe "初回アクセス時の動作" do
    it "ウェルカムアニメーションが表示される" do
      visit root_path
      
      expect(current_path).to eq(welcome_path)
      expect(page).to have_selector("#animation-container")
      expect(page).to have_selector("#rice-field")
      expect(page).to have_selector("#combine")
      expect(page).to have_selector("#cooked-rice")
    end

    it "スキップボタンが表示される" do
      visit welcome_path
      
      expect(page).to have_button("スキップ")
    end
  end

  describe "スキップ機能" do
    it "スキップボタンでトップページに移動する" do
      visit welcome_path
      
      click_button "スキップ"
      
      expect(current_path).to eq(root_path)
      expect(page).to have_selector(".grid")
    end
  end

  describe "セッション管理" do
    it "アニメーション表示後は直接トップページが表示される" do
      # 一度welcome_animationを訪問してセッションを設定
      visit welcome_path
      
      # 再度ルートにアクセス
      visit root_path
      
      expect(current_path).to eq(root_path)
      expect(page).to have_selector(".grid")
      expect(page).not_to have_selector("#animation-container")
    end
  end
end