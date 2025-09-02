class ProfilesController < ApplicationController
  # authenticate_user!の定義はgem
  before_action :authenticate_user!
  before_action :set_user

  def show
    # 公開設定チェック
    unless @user.profile_public || @user == current_user
      redirect_to root_path, alert: "このプロフィールは非公開です。"
      return
    end
  end

  def edit
    # 編集権限チェック（本人のみ）
    unless @user == current_user
      redirect_to root_path, alert: "権限がありません。"
      return
    end
  end

  def update
    # 編集権限チェック（本人のみ）
    unless @user == current_user
      redirect_to root_path, alert: "権限がありません。"
      return
    end

    # プロフィール更新処理
    if @user.update(profile_params)
      redirect_to user_profile_path(@user), notice: "プロフィールを更新しました。"
    else
      # バリデーションエラーで処理できなかったことを示す422コードを返す
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # 各アクションで使うメソッド
  def set_user
    @user = User.find(params[:user_id])
  end

  # ストロングパラメータ
  def profile_params
    params.require(:user).permit(:display_name, :favorite_foods, :disliked_foods, :profile_public)
  end

end
