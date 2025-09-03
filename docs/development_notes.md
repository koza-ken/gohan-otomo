# 開発ノート

## 現在の開発状況（2025年1月）

### ブランチ: 06_post_crud_#9
**完了済み機能**: 投稿のCRUD機能とナビゲーション統合が完成
**次の実装**: Request specの実装中（Task 6）

### 完成済みTask一覧

#### ✅ Task 1: ルーティング設定
- RESTfulルーティング: `resources :posts`
- 7つの標準CRUD routes生成
- ネストしたコメント投稿: `resources :posts do resources :comments, only: [:create] end`

#### ✅ Task 2: PostsControllerの実装  
- **全7アクション完成**: index, show, new, create, edit, update, destroy
- **認証・認可**: ログイン必須（投稿関連）、投稿者のみ編集・削除可能
- **N+1問題対策**: `includes(:user, :comments)` でパフォーマンス最適化
- **ユーザー別投稿**: `params[:user_id]` でクエリパラメータ対応
- **ウェルカムアニメーション統合**: 初回アクセス時の分岐処理

#### ✅ Task 3: 投稿フォームの作成
- **new.html.erb**: 新規投稿フォーム（お米テーマデザイン）
- **edit.html.erb**: 編集フォーム（既存データ表示対応）
- **shared/_error_messages.html.erb**: バリデーションエラー表示

#### ✅ Task 4: 投稿一覧・詳細画面の作成
- **index.html.erb**: 掲示板スタイルの投稿一覧（カード形式）
- **show.html.erb**: 投稿詳細とコメント機能付き
- 画像表示対応（エラー処理付き）
- 投稿者・日時・コメント数表示

#### ✅ Task 5: ナビゲーション統合
- **トップページ統合**: `/` → PostsController#index（投稿一覧）
- **ヘッダーナビゲーション**: 新規投稿、マイ投稿、プロフィール、ログイン・ログアウト
- **ユーザー投稿一覧**: `/posts?user_id=1` でユーザー別投稿表示
- **投稿者名リンク**: クリックでそのユーザーの投稿一覧に遷移
- **権限制御**: 他ユーザーの投稿一覧では投稿ボタン非表示

### 🔄 Task 6: Request spec実装中
**進行状況**: Rails 7対応でRequest spec修正中
- `assigns`メソッド廃止対応（レスポンス内容を直接チェック）
- HTTPメソッドの問題修正（`post "/posts"`形式に変更）
- セッション管理のテスト対応
- コメント投稿フォームのルーティング追加

**残りTask**:
- ⏳ Task 7: System specの実装
- ⏳ Task 8: 動作確認とリファクタリング（セキュリティ見直し含む）

## Learning Mode での開発方法（重要）

### 基本方針
- **小さく分けて確認しながら進める**: 大きな機能を細かいステップに分割
- **理由説明重視**: なぜその実装方法を選ぶのかを必ず説明
- **Rails 7ベストプラクティス**: 最新の推奨方法を採用
- **設計判断の共有**: 複数の選択肢を提示して一緒に判断

### 実装パターン

#### 1. 機能実装の進め方
```
1. 要件整理 → 2. 設計選択肢提示 → 3. 小さな実装 → 4. 動作確認 → 5. 次のステップ
```

**例: PostsController実装**
- Step1: `class PostsController < ApplicationController` の骨組みから開始
- Step2: `before_action` の設定理由を説明
- Step3: `index` アクション一つずつ追加
- Step4: DRY原則（`set_post` メソッド）の導入理由を説明
- Step5: 各アクションの動作確認

#### 2. 設計判断時の考え方
**複数選択肢を提示して理由説明**
- パターン1: メリット・デメリット
- パターン2: メリット・デメリット  
- **推奨**: 理由と根拠

**例: ユーザー投稿一覧の設計**
- パターン1: 新しいUserPostsController作成 → RESTfulだがコード増加
- パターン2: PostsControllerでクエリパラメータ → シンプルだが将来拡張性
- **結論**: 現在の規模ならクエリパラメータで十分

#### 3. テスト駆動での品質確保
- Model spec: バリデーション・アソシエーション・メソッド（88テスト完成）
- Request spec: HTTPレスポンス・認証認可・データ変更（実装中）
- System spec: ブラウザ操作・統合テスト（予定）

### 技術的なアプローチ

#### Rails 7準拠の実装
- **form_with**: `form_for`ではなく`form_with`を使用
- **status指定**: `render :new, status: :unprocessable_entity`
- **N+1対策**: 最初から`includes`を考慮
- **RESTful設計**: 標準的なRailsの慣習に従う

#### コードレビューの視点  
- **DRY原則**: 重複コードの排除（`set_post`等）
- **セキュリティ**: Strong Parameters・認証認可
- **パフォーマンス**: N+1問題・適切なインデックス  
- **保守性**: 理解しやすく変更しやすいコード

## 重要な設計判断

### STI廃止とPost-Comment関連設計への変更 (05_post_model_#7)

**変更理由**:
- RecommendPostとReportPostのSTI設計から、Post（おすすめ投稿）とComment（感想コメント）の関連設計に変更
- おすすめ投稿と感想は本質的に異なる機能であることが判明
- シンプルで理解しやすい設計を優先

**実装順序の変更 (06_post_crud_#9)**:
- 当初: post-models → image-upload → post-crud
- 変更: post-models → post-crud → image-upload
- **理由**: 投稿フォームがないのに画像機能を作るのは非効率

### counter_cache vs delegate の設計判断

**採用**: メソッド形式を維持、delegateは使用しない

```ruby
# 現在の実装
def comments_count
  comments.count
end

# 将来のcounter_cache対応時
def comments_count
  self[:comments_count]  # カラムの値を返すだけ（高速）
end
```

**理由**: 
- delegateを使うと将来のcounter_cache導入時の変更範囲が大きくなる
- メソッド形式なら実装だけ変更、インターフェースは変更不要

### dependent: :nullify の採用理由

**User → Post, Comment**:
```ruby
has_many :posts, dependent: :nullify
has_many :comments, dependent: :nullify
```

**理由**:
- 退会後もコンテンツを保持し、コミュニティ価値を維持
- 「退会済みユーザー」として表示（Safe Navigation Operator使用）

## テスト戦略

### 包括的テストカバレッジ (88テスト)
- **Model specs**: バリデーション、アソシエーション、メソッド
- **FactoryBot**: リアルなテストデータとtrait活用
- **境界値テスト**: 文字数制限、URL形式、関連チェック

### FactoryBot設計パターン
```ruby
# 基本 + trait パターン
factory :post do
  association :user
  title { "テスト商品" }
  description { "これは美味しいご飯のお供です" }
  link { nil }  # デフォルトはnull
  
  trait :with_link do
    link { "https://example.com/product" }
  end
end
```

## Rails 7ベストプラクティス

### ルーティング設計
```ruby
# RESTfulルーティング
resources :posts  # 7つの標準ルート

# ネストルーティング（プロフィール）
resources :users, only: [] do
  resource :profile, only: [:show, :edit, :update]
end
```

### バリデーション設計
- URL形式チェック: `URI::DEFAULT_PARSER.make_regexp(%w[http https])`
- 条件付きバリデーション: `if: :link?` で空の場合をスキップ
- 適切な文字数制限: title(100), description(200), content(300)

## 技術負債と改善点

### 将来的な改善予定
1. **counter_cacheの導入**: N+1問題の解決
2. **バックグラウンドジョブ**: 外部画像取得の非同期化
3. **キャッシュ戦略**: 投稿一覧の高速化
4. **画像最適化**: WebP対応、レスポンシブ画像

### セキュリティ考慮事項
- Strong Parameters徹底使用
- URL形式バリデーション（XSS対策）
- 認証・認可の適切な設定
- Brakeman定期チェック（現在：No warnings）

## 開発環境設定

### 重要な設定ファイル
- `.rubocop.yml`: Rails/Delegateを除外（counter_cache対応のため）
- `spec/support/factory_bot.rb`: テストデータ管理
- `CLAUDE.md`: プロジェクト全体設計
- `docs/branch.md`: ブランチ戦略と実装順序