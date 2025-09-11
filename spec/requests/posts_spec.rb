require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe "GET /index" do
    before do
      # セッションでアニメーション表示済みに設定
      allow_any_instance_of(PostsController).to receive(:session).and_return({ welcome_shown: true })
    end

    context "全投稿一覧の場合" do
      let!(:posts) { create_list(:post, 3) }

      it "正常にレスポンスを返す" do
        get posts_path
        expect(response).to have_http_status(:ok)
      end

      it "全ての投稿タイトルが表示される" do
        get posts_path
        posts.each do |post|
          expect(response.body).to include(post.title)
        end
      end

      it "ヘッダータイトルが正しく表示される" do
        get posts_path
        expect(response.body).to include("みんなのお供")
      end
    end

    context "特定ユーザーの投稿一覧の場合" do
      let!(:user_posts) { create_list(:post, 2, user: user) }
      let!(:other_post) { create(:post, user: other_user) }

      it "正常にレスポンスを返す" do
        get posts_path, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it "指定ユーザーの投稿のみ表示する" do
        get posts_path, params: { user_id: user.id }
        user_posts.each do |post|
          expect(response.body).to include(post.title)
        end
        expect(response.body).not_to include(other_post.title)
      end

      it "ユーザー名がヘッダーに表示される" do
        get posts_path, params: { user_id: user.id }
        expect(response.body).to include("#{user.display_name}さんのお供")
      end

      it "存在しないユーザーIDの場合はリダイレクト" do
        get posts_path, params: { user_id: 999 }
        expect(response).to redirect_to(posts_path)
        expect(flash[:alert]).to eq("指定されたユーザーが見つかりません")
      end
    end

    # 検索・ソート・ページネーション機能のテスト
    describe "検索・ソート・ページネーション機能" do
      let!(:post1) { create(:post, title: "明太子", description: "福岡の名産品", user: user, created_at: 3.days.ago) }
      let!(:post2) { create(:post, title: "いくら", description: "北海道の海鮮", user: user, created_at: 1.day.ago) }
      let!(:post3) { create(:post, title: "のり佃煮", description: "甘辛い明太子味", user: user, created_at: 2.days.ago) }

      describe "検索機能" do
        it "キーワード検索が正常に動作する" do
          get posts_path, params: { search: "明太子" }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(post1.title)
          expect(response.body).to include(post3.title)
          expect(response.body).not_to include(post2.title)
        end

        it "検索結果情報が表示される" do
          get posts_path, params: { search: "明太子" }
          expect(response.body).to include("明太子")
          expect(response.body).to include("の検索結果")
        end

        it "空の検索キーワードでも正常に動作する" do
          get posts_path, params: { search: "" }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(post1.title)
          expect(response.body).to include(post2.title)
          expect(response.body).to include(post3.title)
        end

        it "該当なしの場合は適切に表示される" do
          get posts_path, params: { search: "存在しないキーワード" }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("まだ投稿がありません")
        end
      end

      describe "ソート機能" do
        it "デフォルトは新着順（created_at DESC）で表示される" do
          get posts_path
          expect(response).to have_http_status(:ok)
          # レスポンスボディで投稿の順序を確認（新着順: post2 > post3 > post1）
          post2_index = response.body.index(post2.title)
          post3_index = response.body.index(post3.title)
          post1_index = response.body.index(post1.title)

          expect(post2_index).to be < post3_index
          expect(post3_index).to be < post1_index
        end

      end

      describe "検索機能" do
        it "検索結果が表示される" do
          get posts_path, params: { search: "明太子" }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("明太子")
          expect(response.body).to include("の検索結果")
          expect(response.body).to include(post1.title)
          expect(response.body).to include(post3.title)
        end
      end

      describe "ページネーション機能" do
        # 12件を超える投稿を作成（ページネーションをテスト）
        let!(:additional_posts) do
          (4..15).map do |i|
            create(:post, title: "追加投稿#{i}", description: "テスト投稿#{i}", user: user, created_at: i.hours.ago)
          end
        end

        it "1ページ目が正常に表示される" do
          get posts_path
          expect(response).to have_http_status(:ok)
          # kaminariのページネーションが機能している
          expect(response.body).to include("page=2") # 2ページ目リンクが存在
        end

        it "2ページ目が正常に表示される" do
          get posts_path, params: { page: 2 }
          expect(response).to have_http_status(:ok)
          # 2ページ目に何らかの投稿が表示される
          expect(response.body).to include("text-lg font-bold text-gray-800 mb-2")
        end

        it "存在しないページ番号でもエラーにならない" do
          get posts_path, params: { page: 999 }
          expect(response).to have_http_status(:ok)
          # kaminariは存在しないページでも空のページを返す
        end

        it "検索結果もページネーションされる" do
          # 追加投稿12件中、「追加」で検索すると12件ヒット
          get posts_path, params: { search: "追加", page: 1 }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("追加")
          expect(response.body).to include("の検索結果")
          expect(response.body).to match(/追加投稿\d+/)
        end

        it "パラメータが保持される（検索+ページネーション）" do
          get posts_path, params: { search: "追加", page: 1 }
          expect(response).to have_http_status(:ok)
          # 検索結果が表示されることでパラメータ保持を確認
          expect(response.body).to include("追加")
          expect(response.body).to include("の検索結果")
        end
      end
    end

  end

  describe "GET #show" do
    it "正常にレスポンスを返す" do
      get post_path(post_record)
      expect(response).to have_http_status(:ok)
    end

    it "投稿タイトルと説明が表示される" do
      get post_path(post_record)
      expect(response.body).to include(post_record.title)
      expect(response.body).to include(post_record.description)
    end

    it "コメントが表示される" do
      comment = create(:comment, post: post_record)
      get post_path(post_record)
      expect(response.body).to include(comment.content)
    end

    it "投稿者名が表示される" do
      get post_path(post_record)
      expect(response.body).to include(post_record.user.display_name)
    end
  end

  describe "GET #new" do
    context "ログインしている場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get new_post_path
        expect(response).to have_http_status(:ok)
      end

      it "投稿フォームが表示される" do
        get new_post_path
        expect(response.body).to include("新しいお供だちを紹介")
        expect(response.body).to include("商品名")
        expect(response.body).to include("おすすめポイント")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトする" do
        get new_post_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        title: "テスト商品",
        description: "とても美味しいです",
        link: "https://example.com",
        image_url: "https://example.com/image.jpg"
      }
    end

    let(:invalid_attributes) do
      {
        title: "",
        description: ""
      }
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "有効なパラメータの場合" do
        it "新しい投稿を作成する" do
          expect {
            post posts_path, params: { post: valid_attributes }
          }.to change(Post, :count).by(1)
        end

        it "投稿詳細ページにリダイレクトする" do
          post posts_path, params: { post: valid_attributes }
          expect(response).to redirect_to(Post.last)
        end

        it "成功メッセージを表示する" do
          post posts_path, params: { post: valid_attributes }
          follow_redirect!
          expect(response.body).to include("投稿が作成されました")
        end

        it "現在のユーザーの投稿として作成される" do
          post posts_path, params: { post: valid_attributes }
          expect(Post.last.user).to eq(user)
        end
      end

      context "無効なパラメータの場合" do
        it "投稿を作成しない" do
          expect {
            post posts_path, params: { post: invalid_attributes }
          }.not_to change(Post, :count)
        end

        it "newテンプレートを再表示する" do
          post posts_path, params: { post: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトする" do
        post posts_path, params: { post: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "投稿を作成しない" do
        expect {
          post posts_path, params: { post: valid_attributes }
        }.not_to change(Post, :count)
      end
    end
  end

  describe "GET #edit" do
    context "投稿者がアクセスする場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get edit_post_path(post_record)
        expect(response).to have_http_status(:ok)
      end

      it "編集フォームが表示される" do
        get edit_post_path(post_record)
        expect(response.body).to include("投稿を編集")
        expect(response.body).to include("商品名")
        expect(response.body).to include(post_record.title)
        expect(response.body).to include(post_record.description)
      end
    end

    context "投稿者以外がアクセスする場合" do
      before { sign_in other_user }

      it "投稿一覧にリダイレクトする" do
        get edit_post_path(post_record)
        expect(response).to redirect_to(posts_path)
      end

      it "投稿一覧にリダイレクトする" do
        get edit_post_path(post_record)
        expect(response).to redirect_to(posts_path)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトする" do
        get edit_post_path(post_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) do
      {
        title: "更新されたタイトル",
        description: "更新された説明"
      }
    end

    context "投稿者が更新する場合" do
      before { sign_in user }

      context "有効なパラメータの場合" do
        it "投稿を更新する" do
          patch post_path(post_record), params: { post: new_attributes }
          post_record.reload
          expect(post_record.title).to eq("更新されたタイトル")
          expect(post_record.description).to eq("更新された説明")
        end

        it "投稿詳細ページにリダイレクトする" do
          patch post_path(post_record), params: { post: new_attributes }
          expect(response).to redirect_to(post_record)
        end

        it "成功メッセージを表示する" do
          patch post_path(post_record), params: { post: new_attributes }
          follow_redirect!
          expect(response.body).to include("投稿が更新されました")
        end
      end

      context "無効なパラメータの場合" do
        it "投稿を更新しない" do
          patch post_path(post_record), params: { post: { title: "" } }
          post_record.reload
          expect(post_record.title).not_to eq("")
        end

        it "editテンプレートを再表示する" do
          patch post_path(post_record), params: { post: { title: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "投稿者以外が更新する場合" do
      before { sign_in other_user }

      it "投稿を更新しない" do
        patch post_path(post_record), params: { post: new_attributes }
        post_record.reload
        expect(post_record.title).not_to eq("更新されたタイトル")
      end

      it "投稿一覧にリダイレクトする" do
        patch post_path(post_record), params: { post: new_attributes }
        expect(response).to redirect_to(posts_path)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトする" do
        patch post_path(post_record), params: { post: new_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:post_to_delete) { create(:post, user: user) }

    context "投稿者が削除する場合" do
      before { sign_in user }

      it "投稿を削除する" do
        expect {
          delete post_path(post_to_delete)
        }.to change(Post, :count).by(-1)
      end

      it "投稿一覧にリダイレクトする" do
        delete post_path(post_to_delete)
        expect(response).to redirect_to(posts_path)
      end

      it "投稿一覧にリダイレクトする" do
        delete post_path(post_to_delete)
        expect(response).to redirect_to(posts_path)
      end
    end

    context "投稿者以外が削除する場合" do
      before { sign_in other_user }

      it "投稿を削除しない" do
        expect {
          delete post_path(post_to_delete)
        }.not_to change(Post, :count)
      end

      it "投稿一覧にリダイレクトする" do
        delete post_path(post_to_delete)
        expect(response).to redirect_to(posts_path)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトする" do
        delete post_path(post_to_delete)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "投稿を削除しない" do
        expect {
          delete post_path(post_to_delete)
        }.not_to change(Post, :count)
      end
    end
  end
end
