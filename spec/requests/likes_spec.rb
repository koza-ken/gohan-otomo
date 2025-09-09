require 'rails_helper'

RSpec.describe "Likes", type: :request do
  describe "POST /posts/:post_id/likes" do
    context "ログイン済みユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post_record) { create(:post, user: user) }
      
      before { sign_in user2 }

      it "Turbo Stream形式でいいねを作成できる" do
        expect {
          post post_likes_path(post_record), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change { Like.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end

      it "HTML形式でリクエストした場合はリダイレクトする" do
        post post_likes_path(post_record)
        
        expect(response).to redirect_to(post_record)
        follow_redirect!
        expect(response.body).to include('いいねしました')
      end

      it "同じ投稿に重複していいねはできない" do
        create(:like, user: user2, post: post_record)

        expect {
          post post_likes_path(post_record), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.not_to change { Like.count }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context "未ログインユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:post_record) { create(:post, user: user) }
      
      it "ログインページにリダイレクトされる" do
        post post_likes_path(post_record)
        
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /posts/:post_id/likes/:id" do
    context "ログイン済みユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post_record) { create(:post, user: user) }
      let!(:like_record) { create(:like, user: user2, post: post_record) }
      
      before { sign_in user2 }

      it "Turbo Stream形式でいいねを削除できる" do
        expect {
          delete post_like_path(post_record, like_record), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change { Like.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end

      it "HTML形式でリクエストした場合はリダイレクトする" do
        delete post_like_path(post_record, like_record)
        
        expect(response).to redirect_to(post_record)
        follow_redirect!
        expect(response.body).to include('いいねを取り消しました')
      end

      it "他のユーザーのいいねは削除できない" do
        other_user = create(:user) 
        other_like = create(:like, user: other_user, post: post_record)
        
        # current_user(user2)のいいねは存在するが、other_userのいいねを削除しようとしても
        # controller内では current_user のいいねしか削除されない仕様
        expect {
          delete post_like_path(post_record, other_like), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change { Like.count }.by(-1)  # user2のいいねが削除される
        
        # other_user のいいねは残っている
        expect(Like.exists?(other_like.id)).to be true

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end

      it "存在しないいいねは削除できない" do
        like_record.destroy
        
        expect {
          delete post_like_path(post_record, 99999), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.not_to change { Like.count }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context "未ログインユーザーの場合" do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post_record) { create(:post, user: user) }
      let!(:like_record) { create(:like, user: user2, post: post_record) }
      
      it "ログインページにリダイレクトされる" do
        delete post_like_path(post_record, like_record)
        
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "エラーハンドリング" do
    context "存在しない投稿に対する操作" do
      let!(:user) { create(:user) }
      
      before { sign_in user }

      it "いいね作成時に404エラーを返す" do
        post "/posts/99999/likes"
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end