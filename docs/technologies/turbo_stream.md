# ⚡ Turbo Stream - 完全復習ガイド

## 概要

**Turbo Stream** は Rails 7 標準のリアルタイム部分更新機能。
ページ全体をリロードすることなく、特定のDOM要素のみを動的に更新できます。

### 基本的な特徴
- **部分更新**: ページ全体でなく特定要素のみ更新
- **リアルタイム**: サーバー側の変更を即座に反映
- **Ajax 不要**: 複雑な JavaScript 不要でインタラクティブ機能実現
- **Rails 統合**: Rails 7 で標準搭載

## このアプリでの役割

### 🎯 **なぜTurbo Streamが必要だったのか**

#### **1. ユーザー体験の向上**
```ruby
# ❌ 従来のページリロード
# いいねボタンクリック → ページ全体リロード → 3-5秒待機

# ✅ Turbo Stream による部分更新
# いいねボタンクリック → 0.1秒で即座に反映
```

#### **2. レスポンシブな操作感**
- **いいね機能**: クリック即座に色変化・カウント更新
- **コメント機能**: 投稿後即座にコメント一覧に追加
- **削除機能**: 削除後即座に要素を画面から除去

### 💡 **実装した機能**
1. **いいね/いいね解除**: リアルタイムボタン状態変更
2. **コメント投稿**: ページリロード不要でコメント追加
3. **コメント削除**: 削除確認後即座に要素除去

## 実装内容

### ❤️ **1. いいね機能のTurbo Stream**

#### **Controller実装**
```ruby
# app/controllers/likes_controller.rb
class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @like = @post.likes.build(user: current_user)

    respond_to do |format|
      if @like.save
        format.html { redirect_to @post, notice: 'いいねしました' }
        format.turbo_stream # create.turbo_stream.erb を呼び出し
      else
        format.html { redirect_to @post, alert: 'エラーが発生しました' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(...) }
      end
    end
  end

  def destroy
    @like = @post.likes.find_by(user: current_user)
    @like&.destroy

    respond_to do |format|
      format.html { redirect_to @post, notice: 'いいねを取り消しました' }
      format.turbo_stream # destroy.turbo_stream.erb を呼び出し
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
```

#### **Turbo Stream テンプレート**
```erb
<!-- app/views/likes/create.turbo_stream.erb -->
<%= turbo_stream.replace "like_button_#{@post.id}" do %>
  <%= render 'likes/button', post: @post %>
<% end %>

<!-- app/views/likes/destroy.turbo_stream.erb -->
<%= turbo_stream.replace "like_button_#{@post.id}" do %>
  <%= render 'likes/button', post: @post %>
<% end %>
```

#### **いいねボタンパーシャル**
```erb
<!-- app/views/likes/_button.html.erb -->
<%= turbo_frame_tag "like_button_#{post.id}", class: "flex items-center space-x-1" do %>
  <% if user_signed_in? %>
    <% if post.liked_by?(current_user) %>
      <!-- いいね済み状態 -->
      <%= link_to post_like_path(post, post.likes.find_by(user: current_user)),
                  method: :delete,
                  data: { turbo_method: :delete },
                  class: "text-orange-500 hover:text-orange-600 transition duration-200" do %>
        <span class="text-lg">❤️</span>
      <% end %>
    <% else %>
      <!-- いいね前状態 -->
      <%= link_to post_likes_path(post),
                  method: :post,
                  data: { turbo_method: :post },
                  class: "text-gray-400 hover:text-orange-500 transition duration-200" do %>
        <span class="text-lg">🤍</span>
      <% end %>
    <% end %>
  <% else %>
    <!-- 未ログイン状態（無効化） -->
    <span class="text-gray-300 cursor-not-allowed text-lg">🤍</span>
  <% end %>

  <!-- いいね数表示 -->
  <span class="text-sm text-gray-600"><%= post.likes_count %></span>
<% end %>
```

### 💬 **2. コメント機能のTurbo Stream**

#### **Controller実装**
```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @post, notice: 'コメントを投稿しました' }
        format.turbo_stream
      else
        format.html { redirect_to @post, alert: @comment.errors.full_messages.join(', ') }
        format.turbo_stream { render :create }
      end
    end
  end

  def destroy
    if @comment.user == current_user
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to @post, notice: 'コメントを削除しました' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @post, alert: '削除権限がありません' }
        format.turbo_stream { render :error }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
```

#### **Turbo Stream テンプレート**
```erb
<!-- app/views/comments/create.turbo_stream.erb -->
<!-- コメント一覧を更新（replace使用が重要） -->
<%= turbo_stream.replace "comments_list" do %>
  <%= render partial: 'comments/comment', collection: @post.comments.order(created_at: :desc) %>
<% end %>

<!-- フォームをクリア -->
<%= turbo_stream.replace "comment_form" do %>
  <%= render 'comments/form', post: @post, comment: Comment.new %>
<% end %>

<!-- app/views/comments/destroy.turbo_stream.erb -->
<%= turbo_stream.replace "comments_list" do %>
  <%= render partial: 'comments/comment', collection: @post.comments.order(created_at: :desc) %>
<% end %>
```

#### **コメント表示パーシャル**
```erb
<!-- app/views/comments/_comment.html.erb -->
<div class="bg-white p-4 rounded-lg border border-orange-100" id="comment_<%= comment.id %>">
  <div class="flex justify-between items-start mb-2">
    <div class="flex items-center space-x-2">
      <span class="font-medium text-orange-700"><%= comment.user.display_name %></span>
      <span class="text-xs text-gray-500"><%= comment.time_ago_in_words_japanese %></span>
    </div>

    <!-- 削除ボタン（作成者のみ） -->
    <% if user_signed_in? && comment.deletable_by?(current_user) %>
      <%= link_to post_comment_path(@post || comment.post, comment),
                  method: :delete,
                  data: {
                    turbo_method: :delete,
                    turbo_confirm: "このコメントを削除しますか？"
                  },
                  class: "text-red-500 hover:text-red-700 text-xs" do %>
        削除
      <% end %>
    <% end %>
  </div>

  <div class="text-gray-700 whitespace-pre-line break-all">
    <%= comment.formatted_content %>
  </div>
</div>
```

### 🔧 **3. フォーム設定**

#### **いいねフォーム（リンク形式）**
```erb
<%= link_to post_likes_path(post),
            method: :post,
            data: { turbo_method: :post },
            class: "like-button" do %>
  <!-- ボタン内容 -->
<% end %>
```

#### **コメントフォーム**
```erb
<!-- app/views/comments/_form.html.erb -->
<%= turbo_frame_tag "comment_form" do %>
  <%= form_with model: [post, comment],
                class: "space-y-4",
                data: { turbo: true } do |f| %>

    <%= f.text_area :content,
                     rows: 3,
                     placeholder: "感想やコメントを入力してください（300文字以内）",
                     class: "w-full p-3 border border-orange-200 rounded-lg focus:ring-2 focus:ring-orange-500" %>

    <%= f.submit "コメントする",
                 class: "w-full bg-orange-500 hover:bg-orange-600 text-white font-medium py-2 px-4 rounded-lg transition duration-200" %>
  <% end %>
<% end %>
```

## 学習ポイント

### 🎯 **1. Turbo Stream の基本操作**

#### **主な操作（Actions）**
```erb
<!-- replace: 要素を完全置換 -->
<%= turbo_stream.replace "target_id" do %>
  <div>新しいコンテンツ</div>
<% end %>

<!-- append: 末尾に追加 -->
<%= turbo_stream.append "target_id" do %>
  <div>追加コンテンツ</div>
<% end %>

<!-- prepend: 先頭に追加 -->
<%= turbo_stream.prepend "target_id" do %>
  <div>先頭コンテンツ</div>
<% end %>

<!-- remove: 要素を削除 -->
<%= turbo_stream.remove "target_id" %>

<!-- update: 内容のみ更新 -->
<%= turbo_stream.update "target_id" do %>
  新しいテキストコンテンツ
<% end %>
```

### ⚠️ **2. 重要な設計判断**

#### **replace vs prepend の使い分け**
```erb
<!-- ❌ prepend: 条件分岐表示との相性が悪い -->
<%= turbo_stream.prepend "comments_list" do %>
  <%= render 'comments/comment', comment: @comment %>
<% end %>
<!-- 結果: 「まだコメントがありません」+ 新しいコメント が両方表示される -->

<!-- ✅ replace: 条件分岐表示との相性が良い -->
<%= turbo_stream.replace "comments_list" do %>
  <%= render partial: 'comments/comment', collection: @post.comments.order(created_at: :desc) %>
<% end %>
<!-- 結果: 正しい状態が保たれる -->
```

### 🔐 **3. Rails 7対応の確認ダイアログ**

```erb
<!-- Rails 6まで -->
<%= link_to "削除", post_path(@post),
            data: { confirm: "本当に削除しますか？", method: :delete } %>

<!-- Rails 7 + Turbo -->
<%= link_to "削除", post_path(@post),
            data: {
              turbo_confirm: "本当に削除しますか？",
              turbo_method: :delete
            } %>
```

### 🎨 **4. turbo_frame_tag の活用**

```erb
<!-- 部分更新の範囲を明確に指定 -->
<%= turbo_frame_tag "like_button_#{post.id}" do %>
  <!-- この範囲のみが更新される -->
  <% if post.liked_by?(current_user) %>
    <!-- いいね済み表示 -->
  <% else %>
    <!-- いいね前表示 -->
  <% end %>
<% end %>
```

### 🧪 **5. テスト戦略**

#### **Request Spec**
```ruby
# spec/requests/likes_spec.rb
RSpec.describe 'Likes', type: :request do
  describe 'POST /posts/:post_id/likes' do
    context 'Turbo Stream形式' do
      it 'いいねを作成してTurbo Streamレスポンスを返す' do
        post post_likes_path(post),
             as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include("like_button_#{post.id}")
      end
    end
  end
end
```

#### **System Spec**
```ruby
# spec/system/likes_spec.rb
RSpec.describe "いいね機能", type: :system do
  it 'Ajaxでいいねできる' do
    visit post_path(post)

    # いいねボタンクリック
    click_link '🤍'

    # ページリロードなしで状態が変わることを確認
    expect(page).to have_content('❤️')
    expect(page).to have_content('1') # いいね数
    expect(page).not_to have_content('🤍')
  end
end
```

## 関連ファイル

### 🎮 **Controller ファイル**
```
app/controllers/
├── likes_controller.rb             # いいね機能
└── comments_controller.rb          # コメント機能

app/views/likes/
├── create.turbo_stream.erb         # いいね作成
└── destroy.turbo_stream.erb        # いいね削除

app/views/comments/
├── create.turbo_stream.erb         # コメント作成
└── destroy.turbo_stream.erb        # コメント削除
```

### 🎨 **View ファイル**
```
app/views/shared/
└── _post_image.html.erb            # 投稿表示共通

app/views/likes/
└── _button.html.erb                # いいねボタン

app/views/comments/
├── _comment.html.erb               # コメント表示
└── _form.html.erb                  # コメント投稿フォーム
```

### 🧪 **テストファイル**
```
spec/requests/
├── likes_spec.rb                   # いいね機能テスト
└── comments_spec.rb                # コメント機能テスト

spec/system/
├── likes_spec.rb                   # いいね統合テスト
└── comments_spec.rb                # コメント統合テスト
```

### ⚙️ **設定ファイル**
```
config/routes.rb                    # Turbo Stream対応ルート
app/javascript/application.js      # Turbo読み込み設定
```

## 他プロジェクトでの応用

### 🔄 **汎用的なパターン**

#### **1. 基本的なTurbo Stream実装**
```ruby
class ItemsController < ApplicationController
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.turbo_stream { render :create }
      else
        format.turbo_stream { render :error }
      end
    end
  end
end
```

#### **2. リスト操作パターン**
```erb
<!-- 追加 -->
<%= turbo_stream.append "items_list" do %>
  <%= render 'items/item', item: @item %>
<% end %>

<!-- 削除 -->
<%= turbo_stream.remove "item_#{@item.id}" %>

<!-- 更新 -->
<%= turbo_stream.replace "item_#{@item.id}" do %>
  <%= render 'items/item', item: @item %>
<% end %>
```

#### **3. フォームリセットパターン**
```erb
<!-- フォームをクリア -->
<%= turbo_stream.replace "form_wrapper" do %>
  <%= render 'items/form', item: Item.new %>
<% end %>
```

#### **4. 通知メッセージパターン**
```erb
<!-- 成功メッセージ表示 -->
<%= turbo_stream.prepend "flash_messages" do %>
  <div class="alert alert-success">操作が完了しました</div>
<% end %>
```

### 🎁 **再利用可能コンポーネント**
- **CRUD操作**: 作成・更新・削除の標準的なパターン
- **リスト管理**: アイテム追加・削除・並び替え
- **フォーム処理**: 投稿・編集フォームの統一処理
- **通知システム**: 成功・エラーメッセージの動的表示

---

**Turbo Stream は、お供だちアプリのユーザー体験を劇的に向上させ、
モダンなWebアプリケーションに必要不可欠なリアルタイム機能を提供しています。**