
 ブランチ戦略と実装順序
  1. init
  初期設定

  2. feature/user-authentication

  Issue: ユーザー認証機能の実装

  概要
  Deviseを使用したユーザー登録・ログイン・ログアウト機能を実装

  実装内容
  - Devise gemの追加とセットアップ
  - Userモデルの生成と設定
  - 認証関連のビュー作成（Haml）
  - 表示名フィールドの追加
  - ユーザー登録・ログインフォームのスタイリング（TailwindCSS）
  - RSpecテストの作成（認証フロー）
  - FactoryBot設定（User）

  完了条件
  - ユーザーが登録・ログイン・ログアウトできる
  - 表示名を設定できる
  - 全テストがパス

  -----------------------------------
  📋 Task 1: Devise基盤のセットアップ

  - Devise gemをGemfileに追加
  - rails generate devise:install
  - Devise設定ファイルの調整
  - Bundle install実行

  📋 Task 2: Userモデルの生成と基本設定

  - rails generate devise User
  - Userモデルに表示名フィールド追加
  - マイグレーション実行
  - 基本的なバリデーション設定

  📋 Task 3: Deviseビューの生成とHaml化

  - rails generate devise:views（Deviseのビュー作成）
  - ERBからHamlへの変換
  - TailwindCSSでのスタイリング適用

  📋 Task 4: ユーザー登録フォームのカスタマイズ

  - 表示名フィールドをregistrationフォームに追加
  - Strong parametersの設定
  - バリデーションメッセージの日本語化

  📋 Task 5: 認証フローの確認とテスト準備

  - ログイン・ログアウトの動作確認
  - ApplicationControllerでの認証設定
  - FactoryBot::Userファクトリの作成

  📋 Task 6: RSpecテストの実装

  - Model specの作成（User）
  - Feature specの作成（認証フロー）
  - Request specの作成（必要に応じて）

  📋 Task 7: 動作確認とリファクタリング

  - 全テストの実行・パス確認
  - Rubocop・Brakemanチェック
  - 認証機能の最終動作確認
  -----------------------------------

  3. feature/user-profile

  Issue: ユーザープロフィール機能の実装

  概要
  好きな食べ物・嫌いな食べ物の登録と公開機能

  実装内容
  - Userモデルにプロフィールフィールド追加
  - プロフィール編集画面の作成（Haml）
  - プロフィール表示画面の作成
  - プロフィール公開/非公開設定
  - バリデーション設定
  - RSpec テスト作成
  - FactoryBot更新

  完了条件
  - ユーザーがプロフィール情報を登録・編集できる
  - 他のユーザーがプロフィールを閲覧できる
  - 公開設定が機能する

  ----------------------
 📋 Task 1: データベース設計とマイグレーション

  - プロフィールフィールドのマイグレーション作成
  - favorite_foods:text, disliked_foods:text, profile_public:boolean
  - マイグレーション実行とDB更新確認

  📋 Task 2: Userモデルの更新

  - プロフィールフィールドのバリデーション追加
  - profile_public?メソッドの実装
  - scope :with_public_profileの追加
  - Model specの作成・更新

  📋 Task 3: ルーティング設計

  - プロフィール関連ルートの追加
  - resources :profilesまたはusersネストの実装
  - ルーティングの動作確認

  📋 Task 4: Profilesコントローラーの実装

  - ProfilesControllerの作成
  - show, edit, updateアクションの実装
  - 認証・認可ロジックの設定
  - Strong parametersの設定

  📋 Task 5: プロフィール表示ビューの作成

  - profiles/show.html.erbの作成
  - 米テーマデザインの適用
  - ユーザー情報・好き嫌いな食べ物の表示
  - 公開設定に応じた表示制御

  📋 Task 6: プロフィール編集ビューの作成

  - profiles/edit.html.erbの作成
  - プロフィール編集フォームの実装
  - テキストエリア・チェックボックスの設定
  - 米テーマフォームデザインの適用

  📋 Task 7: ナビゲーション更新

  - ヘッダーにプロフィールリンクの追加
  - ログイン時のドロップダウンメニュー拡張
    （ハンバーガーメニューstimulus）
  - プロフィール編集へのアクセス導線追加

  📋 Task 8: Request specの実装

  - spec/requests/profiles_spec.rbの作成
  - プロフィール表示・編集・更新のテスト
  - アクセス制御・認可のテスト実装

  📋 Task 9: System specの実装

  - spec/system/user_profile_spec.rbの作成
  - プロフィール表示・編集の統合テスト
  - フォーム入力・更新フローのテスト

  📋 Task 10: FactoryBot更新

  - spec/factories/users.rbにプロフィール用trait追加
  - with_profile, private_profileトレイトの実装

  📋 Task 11: 動作確認とリファクタリング

  - 全テストの実行・パス確認
  - Rubocop・Brakemanチェック
  - プロフィール機能の最終動作確認
  - レスポンシブ対応の確認
  ----------------------

  4. feature/post-models

  Issue: 投稿・コメントモデルの実装

  概要
  PostモデルとCommentモデルの実装（STI廃止、シンプルな関連に変更）

  実装内容
  - Postモデルの作成（おすすめ投稿）
  - Commentモデルの作成（感想コメント）
  - 必要な属性とバリデーションの定義
  - アソシエーション設定（User, Post, Comment）
  - RSpec テスト作成
  - FactoryBot設定

  完了条件
  - Post-Comment関連が正しく動作する
  - バリデーションが機能する
  - 全テストがパス

　---------------------------
  Task 1: データベース設計とマイグレーション

  - Postモデル用のマイグレーション作成（おすすめ投稿）
  - Commentモデル用のマイグレーション作成（感想コメント）
  - title（商品名）、description（おすすめポイント）、link、image_url等の設計
  - user_id、post_id（外部キー）、適切なインデックス設定
  - マイグレーション実行とDB更新確認

  Task 2: Postモデルの作成

  - app/models/post.rbの作成
  - Userとのアソシエーション設定（belongs_to :user）
  - Commentとの関連設定（has_many :comments）
  - バリデーション設定（title, description必須）
  - 商品名検索などの基本メソッド実装

  Task 3: Commentモデルの作成

  - app/models/comment.rbの作成
  - User、Postとのアソシエーション設定
  - バリデーション設定（content必須）
  - 感想コメント関連メソッド実装

  Task 4: モデル間のアソシエーション設定

  - Userモデルにpost、commentとの関連追加
  - 依存関係の設定（dependent: :destroy等）
  - counter_cacheの検討・実装

  Task 5: Model specの実装

  - spec/models/post_spec.rbの作成
  - spec/models/comment_spec.rbの作成
  - バリデーション、アソシエーション、メソッドの全テスト
  - User関連のテスト更新

  Task 6: FactoryBot設定

  - spec/factories/posts.rbの作成
  - spec/factories/comments.rbの作成
  - 各種トレイト実装（with_comments等）
  - 画像付き、リンク付き等の各種トレイト

  Task 7: 動作確認とリファクタリング

  - 全テストの実行・パス確認
  - Rubocop・Brakemanチェック
  - STIモデルの動作確認（コンソール）
  ---------------------------


  5. feature/post-crud

  Issue: 投稿のCRUD機能実装

  概要
  投稿の作成・表示・編集・削除機能（画像なしの基本機能）

  実装内容
  - 投稿コントローラーの実装
  - 投稿フォーム作成（基本項目のみ）
  - 投稿詳細表示
  - 投稿一覧表示
  - 投稿編集・削除機能
  - 認可設定（投稿者のみ編集可能）
  - RSpec テスト作成（コントローラー・システム）

  完了条件
  - 投稿の作成・表示・編集・削除ができる
  - 投稿一覧・詳細表示ができる
  - 適切な認可が設定されている

  ---------------------------
  📋 Task 1: ルーティング設定

  - config/routes.rbに投稿関連ルートの追加
  - resources :posts でRESTfulルート設定
  - 認証必須のルート設定

  📋 Task 2: PostsControllerの実装

  - app/controllers/posts_controller.rbの作成
  - index, show, new, create, edit, update, destroyアクション
  - 認証・認可の設定（before_action）
  - Strong parametersの設定

  📋 Task 3: 投稿フォームの作成

  - app/views/posts/new.html.erbの作成
  - app/views/posts/edit.html.erbの作成
  - 米テーマデザインの適用
  - バリデーションエラー表示

  📋 Task 4: 投稿一覧・詳細画面の作成

  - app/views/posts/index.html.erbの作成
  - app/views/posts/show.html.erbの作成
  - 投稿者情報・日時の表示
  - 編集・削除ボタンの条件表示

  📋 Task 5: ナビゲーション統合

  - ヘッダーに「投稿する」リンクの追加
  - 投稿一覧へのアクセス導線
  - ユーザーの投稿一覧表示

  📋 Task 6: Request specの実装

  - spec/requests/posts_spec.rbの作成
  - 投稿のCRUD操作テスト
  - 認証・認可のテスト
  - リダイレクト・エラーハンドリングのテスト

  📋 Task 7: System specの実装

  - spec/system/posts_spec.rbの作成
  - 投稿作成・編集・削除の統合テスト
  - フォーム入力・バリデーションエラーのテスト

  📋 Task 8: 動作確認とリファクタリング

  - 全テストの実行・パス確認
  - Rubocop・Brakemanチェック
  - 投稿機能の最終動作確認
  ---------------------------

  6. feature/image-upload

  Issue: 画像アップロード機能の実装

  概要
  Active Storageを使用した画像アップロードとハイブリッド画像取得

  実装内容
  - Active Storage設定
  - image_processing gem追加
  - 画像アップロード機能（投稿フォームに追加）
  - 画像リサイズ・最適化
  - 外部サイト画像取得機能（OGP等）
  - プレースホルダー画像設定
  - RSpec テスト作成

  完了条件
  - 画像をアップロードできる
  - 外部リンクから画像を取得できる
  - 適切なフォールバック機能

  実装内容
  - 投稿コントローラーの実装
  - 投稿フォーム作成（タイプ別）
  - 投稿詳細表示
  - 投稿一覧表示
  - 投稿編集・削除機能
  - 認可設定（投稿者のみ編集可能）
  - RSpec テスト作成（コントローラー・フィーチャー）

  完了条件
  - 投稿タイプ別にフォームが機能する
  - 投稿の一覧・詳細表示ができる
  - 適切な認可が設定されている

  7. feature/post-listing

  Issue: 投稿一覧とフィルター機能

  概要
  投稿一覧の表示とタイプ別フィルター、検索機能

  実装内容
  - 投稿一覧ページの実装
  - 投稿タイプ別フィルター
  - ページネーション
  - 検索機能（キーワード）
  - ソート機能（新着・人気）
  - プロフィール情報の表示
  - モバイル対応デザイン
  - RSpec テスト作成

  完了条件
  - 投稿をタイプ別にフィルターできる
  - 検索・ソート機能が動作する
  - モバイルファーストデザイン

  8. feature/like-system

  Issue: いいね機能の実装

  概要
  投稿に対するいいね機能とカウント表示

  実装内容
  - Likeモデルの作成
  - いいね/いいね取消の実装
  - いいね数の表示
  - 非同期いいね機能（Turbo）
  - 重複いいね防止
  - RSpec テスト作成
  - FactoryBot設定

  完了条件
  - ユーザーが投稿にいいねできる
  - いいね状態が適切に表示される
  - 非同期で動作する

  9. feature/sns-integration

  Issue: SNS連携機能の実装

  概要
  X（旧Twitter）シェア機能の実装

  実装内容
  - シェアボタンの実装
  - 投稿タイプ別シェアテキスト
  - OGPメタタグ設定
  - SNSプレビュー対応
  - RSpec テスト作成

  完了条件
  - 投稿をXにシェアできる
  - 投稿タイプに応じたシェア内容
  - OGP対応

  10. feature/responsive-design

  Issue: レスポンシブデザインの実装

  概要
  モバイルファーストのレスポンシブデザイン実装

  実装内容
  - TailwindCSS v4設定の最適化
  - モバイル向けナビゲーション
  - タブレット・デスクトップ対応
  - 画像レスポンシブ対応
  - フォームのモバイル最適化
  - パフォーマンス最適化

  完了条件
  - 全デバイスで適切に表示される
  - モバイルファースト設計
  - 良好なUX

  11. feature/deployment

  Issue: デプロイメント設定

  概要
  Renderへのデプロイ設定

  実装内容
  - 本番環境設定
  - 環境変数設定
  - データベース設定
  - 画像ストレージ設定（S3等）
  - CI/CDパイプライン調整

  完了条件
  - 本番環境で正常動作する
  - CI/CDが正しく動作する
