class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :create, :destroy ]
  before_action :set_comment, only: [ :destroy ]
  before_action :authorize_comment_deletion, only: [ :destroy ]

  # POST /posts/:post_id/comments
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream  # create.turbo_stream.erb を使用
        format.html { redirect_to @post, notice: "コメントを投稿しました。" }
      else
        format.turbo_stream  # エラー用のレスポンス
        format.html { redirect_to @post, alert: "コメントの投稿に失敗しました。" }
      end
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    @comment.destroy

    respond_to do |format|
      format.turbo_stream  # destroy.turbo_stream.erb を使用
      format.html { redirect_to @post, notice: "コメントを削除しました。" }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_comment_deletion
    unless @comment.deletable_by?(current_user)
      redirect_to @post, alert: "このコメントを削除する権限がありません。"
    end
  end
end
