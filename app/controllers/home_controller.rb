class HomeController < ApplicationController
  def index
    # 初回アクセス時はアニメーションを表示
    unless session[:welcome_shown]
      redirect_to welcome_path
      return
    end
    
    # 通常のトップページ表示
  end

  def welcome_animation
    # アニメーション表示フラグを設定
    session[:welcome_shown] = true
  end

  def skip_animation
    # アニメーションをスキップしてトップページへ
    session[:welcome_shown] = true
    redirect_to root_path
  end
end
