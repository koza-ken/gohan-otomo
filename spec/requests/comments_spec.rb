require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, display_name: 'other_user', email: 'other@example.com') }
  let(:post_record) { create(:post, user: user) }

  describe 'POST /posts/:post_id/comments' do
    context 'ログイン済みユーザーの場合' do
      before { sign_in user }

      context '有効なパラメーターの場合' do
        let(:valid_params) do
          {
            comment: {
              content: 'とても美味しかったです！'
            }
          }
        end

        it 'コメントが作成される' do
          expect {
            post post_comments_path(post_record), params: valid_params
          }.to change(Comment, :count).by(1)
        end

        it '作成されたコメントが正しい属性を持つ' do
          post post_comments_path(post_record), params: valid_params
          
          created_comment = Comment.last
          expect(created_comment.content).to eq('とても美味しかったです！')
          expect(created_comment.user).to eq(user)
          expect(created_comment.post).to eq(post_record)
        end

        context 'HTML形式の場合' do
          it '投稿詳細ページにリダイレクトされる' do
            post post_comments_path(post_record), params: valid_params
            expect(response).to redirect_to(post_record)
          end

          it '成功メッセージが表示される' do
            post post_comments_path(post_record), params: valid_params
            follow_redirect!
            expect(response.body).to include('コメントを投稿しました')
          end
        end

        context 'Turbo Stream形式の場合' do
          let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

          it 'turbo_streamレスポンスが返される' do
            post post_comments_path(post_record), 
                 params: valid_params, 
                 headers: turbo_headers
            
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to include('text/vnd.turbo-stream.html')
          end

          it 'turbo_streamコンテンツが含まれる' do
            post post_comments_path(post_record), 
                 params: valid_params, 
                 headers: turbo_headers
            
            expect(response.body).to include('turbo-stream')
            expect(response.body).to include('comments_list')
          end
        end
      end

      context '無効なパラメーターの場合' do
        let(:invalid_params) do
          {
            comment: {
              content: ''
            }
          }
        end

        it 'コメントが作成されない' do
          expect {
            post post_comments_path(post_record), params: invalid_params
          }.not_to change(Comment, :count)
        end

        context 'HTML形式の場合' do
          it '投稿詳細ページにリダイレクトされる' do
            post post_comments_path(post_record), params: invalid_params
            expect(response).to redirect_to(post_record)
          end

          it 'エラーメッセージが表示される' do
            post post_comments_path(post_record), params: invalid_params
            follow_redirect!
            expect(response.body).to include('コメントの投稿に失敗しました')
          end
        end

        context 'Turbo Stream形式の場合' do
          let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

          it 'turbo_streamレスポンスが返される' do
            post post_comments_path(post_record), 
                 params: invalid_params, 
                 headers: turbo_headers
            
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to include('text/vnd.turbo-stream.html')
          end
        end
      end

      context '存在しない投稿IDの場合' do
        it '404エラーが返される' do
          post post_comments_path(999), params: { comment: { content: 'test' } }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログインしていないユーザーの場合' do
      let(:valid_params) do
        {
          comment: {
            content: 'ログインなしのコメント'
          }
        }
      end

      it 'コメントが作成されない' do
        expect {
          post post_comments_path(post_record), params: valid_params
        }.not_to change(Comment, :count)
      end

      it 'ログインページにリダイレクトされる' do
        post post_comments_path(post_record), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /posts/:post_id/comments/:id' do
    let!(:comment) { create(:comment, user: user, post: post_record) }

    context 'ログイン済みユーザーの場合' do
      before { sign_in user }

      context 'コメント作成者の場合' do
        it 'コメントが削除される' do
          expect {
            delete post_comment_path(post_record, comment)
          }.to change(Comment, :count).by(-1)
        end

        context 'HTML形式の場合' do
          it '投稿詳細ページにリダイレクトされる' do
            delete post_comment_path(post_record, comment)
            expect(response).to redirect_to(post_record)
          end

          it '成功メッセージが表示される' do
            delete post_comment_path(post_record, comment)
            follow_redirect!
            expect(response.body).to include('コメントを削除しました')
          end
        end

        context 'Turbo Stream形式の場合' do
          let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

          it 'turbo_streamレスポンスが返される' do
            delete post_comment_path(post_record, comment), headers: turbo_headers
            
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to include('text/vnd.turbo-stream.html')
          end

          it 'turbo_streamコンテンツが含まれる' do
            delete post_comment_path(post_record, comment), headers: turbo_headers

            expect(response.body).to include('turbo-stream')
            expect(response.body).to include('comments_list')
            expect(response.body).to include('comments_count')
          end
        end
      end

      context 'コメント作成者でない場合' do
        let!(:other_comment) { create(:comment, user: other_user, post: post_record) }

        it 'コメントが削除されない' do
          expect {
            delete post_comment_path(post_record, other_comment)
          }.not_to change(Comment, :count)
        end

        it '投稿詳細ページにリダイレクトされる' do
          delete post_comment_path(post_record, other_comment)
          expect(response).to redirect_to(post_record)
        end

        it 'エラーメッセージが表示される' do
          delete post_comment_path(post_record, other_comment)
          follow_redirect!
          expect(response.body).to include('このコメントを削除する権限がありません')
        end
      end

      context '存在しないコメントIDの場合' do
        it '404エラーが返される' do
          delete post_comment_path(post_record, 999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログインしていないユーザーの場合' do
      it 'コメントが削除されない' do
        expect {
          delete post_comment_path(post_record, comment)
        }.not_to change(Comment, :count)
      end

      it 'ログインページにリダイレクトされる' do
        delete post_comment_path(post_record, comment)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end