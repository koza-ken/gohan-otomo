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
        expect(response.body).to include("ご飯のお供掲示板")
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
        expect(response.body).to include("#{user.display_name}さんの投稿")
      end

      it "存在しないユーザーIDの場合は404エラー" do
        get posts_path, params: { user_id: 999 }
        expect(response).to have_http_status(:not_found)
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
        expect(response.body).to include("新しいお米のお供を投稿")
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
