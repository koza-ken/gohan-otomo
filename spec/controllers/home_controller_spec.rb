require 'rails_helper'

RSpec.describe "HomeController", type: :request do
  describe "GET /" do
    context "初回アクセス時（welcome_shownセッションなし）" do
      it "welcomeページにリダイレクトする" do
        get root_path
        expect(response).to redirect_to(welcome_path)
      end
    end

    context "welcome_shownセッションがある場合" do
      it "正常にレスポンスを返す" do
        # セッションを設定してからリクエスト
        get welcome_path  # まずwelcome_animationでセッションを設定
        get root_path     # その後indexにアクセス
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("grid") # トップページのグリッドが含まれる
      end
    end
  end

  describe "GET /welcome" do
    it "正常にレスポンスを返す" do
      get welcome_path
      expect(response).to have_http_status(:success)
    end

    it "アニメーション要素が含まれる" do
      get welcome_path
      expect(response.body).to include("animation-container")
      expect(response.body).to include("rice-field")
      expect(response.body).to include("combine")
      expect(response.body).to include("cooked-rice")
    end

    it "スキップボタンが含まれる" do
      get welcome_path
      expect(response.body).to include("スキップ")
    end
  end

  describe "POST /skip_animation" do
    it "root_pathにリダイレクトする" do
      post skip_animation_path
      expect(response).to redirect_to(root_path)
    end

    it "リダイレクト後はindexページが表示される" do
      post skip_animation_path
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("grid")
    end
  end
end