require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user, :with_profile) }
  let(:private_user) { create(:user, :with_private_profile) }
  let(:other_user) { create(:user, :with_profile) }

  describe "GET /users/:user_id/profile" do
    context "認証されていない場合" do
      it "ログインページにリダイレクトする" do
        get user_profile_path(user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "認証されている場合" do
      before { sign_in user }

      context "自分のプロフィールを表示" do
        it "正常にレスポンスを返す" do
          get user_profile_path(user)
          expect(response).to have_http_status(:success)
        end

        it "プロフィール情報が表示される" do
          get user_profile_path(user)
          expect(response.body).to include(user.display_name)
          expect(response.body).to include(user.favorite_foods)
          expect(response.body).to include(user.disliked_foods)
          expect(response.body).to include(user.email) # 本人のみ表示
        end

        it "編集リンクが表示される" do
          get user_profile_path(user)
          expect(response.body).to include("プロフィールを編集")
        end
      end

      context "他人の公開プロフィールを表示" do
        it "正常にレスポンスを返す" do
          get user_profile_path(other_user)
          expect(response).to have_http_status(:success)
        end

        it "プロフィール情報が表示される（メールアドレス除く）" do
          get user_profile_path(other_user)
          expect(response.body).to include(other_user.display_name)
          expect(response.body).to include(other_user.favorite_foods)
          expect(response.body).not_to include(other_user.email) # 他人には非表示
        end

        it "編集リンクが表示されない" do
          get user_profile_path(other_user)
          expect(response.body).not_to include("プロフィールを編集")
        end
      end

      context "他人の非公開プロフィールを表示" do
        it "ルートパスにリダイレクトする" do
          get user_profile_path(private_user)
          expect(response).to redirect_to(root_path)
        end

        it "アラートメッセージが表示される" do
          get user_profile_path(private_user)
          expect(flash[:alert]).to eq("このプロフィールは非公開です。")
        end
      end
    end
  end

  describe "GET /users/:user_id/profile/edit" do
    context "認証されていない場合" do
      it "ログインページにリダイレクトする" do
        get edit_user_profile_path(user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "認証されている場合" do
      before { sign_in user }

      context "自分のプロフィール編集" do
        it "正常にレスポンスを返す" do
          get edit_user_profile_path(user)
          expect(response).to have_http_status(:success)
        end

        it "編集フォームが表示される" do
          get edit_user_profile_path(user)
          expect(response.body).to include("プロフィール編集")
          expect(response.body).to include(user.display_name)
          expect(response.body).to include(user.favorite_foods)
          expect(response.body).to include(user.disliked_foods)
        end
      end

      context "他人のプロフィール編集を試みる" do
        it "ルートパスにリダイレクトする" do
          get edit_user_profile_path(other_user)
          expect(response).to redirect_to(root_path)
        end

        it "権限エラーメッセージが表示される" do
          get edit_user_profile_path(other_user)
          expect(flash[:alert]).to eq("権限がありません。")
        end
      end
    end
  end

  describe "PATCH /users/:user_id/profile" do
    context "認証されていない場合" do
      it "ログインページにリダイレクトする" do
        patch user_profile_path(user), params: { user: { display_name: "新しい名前" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "認証されている場合" do
      before { sign_in user }

      context "有効なパラメータで更新" do
        let(:valid_params) do
          {
            user: {
              display_name: "新しいユーザー名",
              favorite_foods: "新しい好きな食べ物",
              disliked_foods: "新しい嫌いな食べ物",
              profile_public: false
            }
          }
        end

        it "プロフィールページにリダイレクトする" do
          patch user_profile_path(user), params: valid_params
          expect(response).to redirect_to(user_profile_path(user))
        end

        it "成功メッセージが表示される" do
          patch user_profile_path(user), params: valid_params
          follow_redirect!
          expect(response.body).to include("プロフィールを更新しました")
        end

        it "ユーザー情報が更新される" do
          patch user_profile_path(user), params: valid_params
          user.reload
          expect(user.display_name).to eq("新しいユーザー名")
          expect(user.favorite_foods).to eq("新しい好きな食べ物")
          expect(user.disliked_foods).to eq("新しい嫌いな食べ物")
          expect(user.profile_public).to be false
        end
      end

      context "無効なパラメータで更新" do
        let(:invalid_params) do
          {
            user: {
              display_name: "a" * 21, # 20文字超過
              favorite_foods: "a" * 201 # 200文字超過
            }
          }
        end

        it "編集ページを再表示する" do
          patch user_profile_path(user), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "エラーメッセージが表示される" do
          patch user_profile_path(user), params: invalid_params
          expect(response.body).to include("入力内容を確認してください")
        end

        it "ユーザー情報が更新されない" do
          original_name = user.display_name
          patch user_profile_path(user), params: invalid_params
          user.reload
          expect(user.display_name).to eq(original_name)
        end
      end

      context "他人のプロフィール更新を試みる" do
        it "ルートパスにリダイレクトする" do
          patch user_profile_path(other_user), params: { user: { display_name: "ハック" } }
          expect(response).to redirect_to(root_path)
        end

        it "他人の情報が更新されない" do
          original_name = other_user.display_name
          patch user_profile_path(other_user), params: { user: { display_name: "ハック" } }
          other_user.reload
          expect(other_user.display_name).to eq(original_name)
        end
      end
    end
  end
end
