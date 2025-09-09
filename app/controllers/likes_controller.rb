class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  # POST /posts/:post_id/likes
  def create
    @like = @post.likes.build(user: current_user)

    respond_to do |format|
      if @like.save
        format.turbo_stream
        format.html { redirect_to @post, notice: "いいねしました" }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_button_#{@post.id}", partial: "likes/button", locals: { post: @post }) }
        format.html { redirect_to @post, alert: "いいねに失敗しました" }
      end
    end
  end

  # DELETE /posts/:post_id/likes/:id
  def destroy
    @like = @post.likes.find_by(user: current_user)

    respond_to do |format|
      if @like&.destroy
        format.turbo_stream
        format.html { redirect_to @post, notice: "いいねを取り消しました" }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_button_#{@post.id}", partial: "likes/button", locals: { post: @post }) }
        format.html { redirect_to @post, alert: "いいねの取り消しに失敗しました" }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
