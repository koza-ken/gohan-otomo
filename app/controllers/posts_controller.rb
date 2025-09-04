class PostsController < ApplicationController
  # 投稿・編集・削除のみログイン必須（閲覧はログイン不要）
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :check_post_owner, only: [ :edit, :update, :destroy ]

  # GET / および GET /posts （ログイン不要）
  def index
    # 初回アクセス時はアニメーションを表示（開発中は一時的に無効化）
    # unless session[:welcome_shown]
    #   redirect_to welcome_path
    #   return
    # end

    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @posts = @user.posts.includes(:user, :comments).order(created_at: :desc)
    else
      @posts = Post.includes(:user, :comments).order(created_at: :desc)
    end
  end

  # GET /posts/1 （ログイン不要）
  def show
    @comments = @post.comments.includes(:user).order(created_at: :desc)
    # 詳細ページのコメント投稿フォームに空のオブジェクトを渡すため
    @comment = Comment.new
  end

  # GET /posts/new （ログイン必須）
  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "投稿が作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /posts/1/edit （ログイン必須・投稿者のみ）
  def edit
    # @postは既にset_postで設定済み
    # 何も書かなくていい
  end

  # PATCH/PUT /posts/1 （ログイン必須・投稿者のみ）
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "投稿が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 （ログイン必須・投稿者のみ）
  def destroy
    @post.destroy
    redirect_to posts_path, notice: "投稿が削除されました。"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_post_owner
    redirect_to posts_path, alert: "この操作は許可されていません。" unless @post.user == current_user
  end

  # ストロングパラメータ
  def post_params
    params.require(:post).permit(:title, :description, :link, :image_url, :image)
  end

  # ウェルカムアニメーション表示（ログイン不要）
  def welcome_animation
    # アニメーション画面を表示（セッション更新は別ルートで行う）
  end

  # アニメーションをスキップしてトップページへ
  def skip_animation
    session[:welcome_shown] = true
    redirect_to root_path
  end
end
