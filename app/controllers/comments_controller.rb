class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]
  before_action :authorize_comment_deletion, only: [:destroy]

  # POST /posts/:post_id/comments
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            # 新しいコメントをリストの先頭に追加
            turbo_stream.prepend("comments_list", partial: "comments/comment", locals: { comment: @comment }),
            # フォームをリセット
            turbo_stream.replace("comment_form", partial: "comments/form", locals: { post: @post, comment: Comment.new }),
            # コメント数を更新
            turbo_stream.replace("comments_count", @post.comments.count)
          ]
        end
        format.html { redirect_to @post, notice: 'コメントを投稿しました。' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { post: @post, comment: @comment })
        end
        format.html { redirect_to @post, alert: 'コメントの投稿に失敗しました。' }
      end
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    @comment.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # コメントを削除
          turbo_stream.remove("comment_#{@comment.id}"),
          # コメント数を更新
          turbo_stream.replace("comments_count", @post.comments.count)
        ]
      end
      format.html { redirect_to @post, notice: 'コメントを削除しました。' }
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
      redirect_to @post, alert: 'このコメントを削除する権限がありません。'
    end
  end
end