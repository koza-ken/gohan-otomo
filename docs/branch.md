
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


  5. 05_post_model_#7 ✅ 完了

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

  6. 07_image-upload_#8 ✅ 05_post_model_#7完了後

  Issue: 画像アップロード機能の実装

  概要
  Active Storageを使用した画像アップロードとハイブリッド画像取得方式

  実装内容
  - Active Storage設定
  - image_processing gem追加
  - 画像アップロード機能（投稿フォームに追加）
  - 画像リサイズ・最適化（variant使用）
  - 基本的な画像表示機能（アップロード > 外部URL > プレースホルダー）
  - RSpec テスト作成
  - セキュリティ・パフォーマンス対策

  完了条件
  - 画像をアップロードできる
  - 外部URL画像の基本表示ができる
  - 適切なフォールバック機能が動作する
  - 画像関連テストが完備されている

  ---------------------------
  📋 Task 1: Active Storage設定とgem追加

  - rails active_storage:install実行
  - image_processing gemをGemfileに追加
  - bundle install実行
  - libvips設定の確認（Docker環境）

  📋 Task 2: 画像アップロード機能の実装

  - Postモデルにhas_one_attached :image追加
  - 画像バリデーションの実装（サイズ、形式制限）
  - PostsControllerのstrong parametersに:image追加

  📋 Task 3: 投稿フォームの画像アップロード対応

  - new.html.erb、edit.html.erbにfile_fieldを追加
  - 画像プレビュー機能の実装（JavaScript）
  - ファイル形式・サイズの入力制限表示

  📋 Task 4: 画像表示機能の実装

  - 投稿詳細・一覧での画像表示
  - image.variant()でのリサイズ設定
  - エラーハンドリング（onerror属性）
  - レスポンシブ画像表示

  📋 Task 5: テストの実装

  - spec/models/post_spec.rbに画像関連テスト追加
  - spec/system/posts_spec.rbに画像アップロードテスト追加
  - spec/requests/posts_spec.rbに画像パラメータテスト追加
  - FactoryBotにwith_imageトレイト追加

  📋 Task 6: セキュリティとパフォーマンス対策

  - 画像サイズ制限の強化（10MB制限等）
  - ファイル形式制限（JPEG, PNG, WebP等）
  - variantでの画像最適化設定
  - 動作確認とリファクタリング
  ---------------------------

  7. 08_post_listing_#10 ✅ 完了

  Issue: 投稿一覧・検索・ソート・ページネーション機能

  概要
  投稿一覧の表示と検索機能、ソート機能、ページネーション機能

  実装内容
  - 投稿一覧ページの検索・ソート拡張
  - キーワード検索機能（title・description対象）
  - ソート機能（新着順・古い順）
  - ページネーション（kaminari）
  - データ永続化（Docker Volume + 自動seed）
  - レスポンシブUI最適化
  - 包括的RSpecテスト作成

  完了条件 ✅
  - キーワード検索機能が動作する
  - ソート機能（新着順・古い順）が動作する
  - ページネーション機能が動作する
  - 192テスト（100%成功）

  ---------------------------
  ✅ Task 1: 基本的な投稿一覧機能の拡張 (完了)

  - PostsControllerのindexアクションを検索・ソート対応に拡張
  - Strong Parametersに検索・ソートパラメータ追加
  - 現在の投稿一覧ビューの確認・改良準備
  - パフォーマンス考慮のクエリ最適化

  ✅ Task 2: 検索機能の実装 (完了)

  - Postモデルにsearchスコープメソッド追加（search_by_keyword）
  - title・descriptionでのILIKE検索実装
  - 検索フォームUI実装（投稿一覧上部）
  - 検索結果の「該当なし」状態ハンドリング
  - SQLインジェクション対策確認（名前付きプレースホルダー）

  ✅ Task 3: ソート機能の実装 (完了)

  - 新着順（created_at desc）・古い順（asc）実装
  - 将来のいいね数順に対応した拡張性設計
  - ソート選択UI実装（ドロップダウン）
  - デフォルトソート設定（新着順）
  - URLパラメータでのソート状態管理

  ✅ Task 4: ページネーション実装 (完了)

  - kaminari gem追加・設定（12投稿/ページ）
  - ページネーションビューの実装・お米テーマカスタマイズ
  - ページサイズ設定・ウィンドウ設定
  - ページネーションと検索/ソートの連携
  - パラメータ保持対応

  ⭐ Task 5: フィルター機能の実装 (スキップ)

  - 現在の検索・ソート機能で十分な機能性を提供
  - 将来的にカテゴリ機能実装時に再検討

  ✅ Task 6: レスポンシブUI改善 (完了確認)

  - グリッドレイアウトの最適化（TailwindCSS）
  - カード型投稿デザインの実装
  - モバイル向け検索・フィルターUI
  - タッチフレンドリーなボタンサイズ
  - 画像レスポンシブ対応強化

  ✅ Task 7: RSpecテスト実装 (完了)

  - Request spec: 検索・ソート・ページネーションテスト（13テスト）
  - Model spec: search_by_keywordスコープメソッドテスト（7テスト）
  - 既存テスト修正（失敗テスト1件修正）
  - エッジケース対応テスト
  - テスト総数: 172→192テスト（100%成功）

  ✅ Task 8: データ永続化とパフォーマンス最適化 (完了)

  - N+1問題対策（includes適用）
  - Docker Volume永続化設定
  - 自動seed生成（33件のテストデータ）
  - 効率的クエリ順序（検索→ソート→ページネーション→includes）
  ---------------------------

  8. 09_like_#11 ✅ 完成

  Issue: いいね機能の実装（投稿のみ）

  概要
  投稿に対するいいね機能とカウント表示（コメント機能は対象外）

  実装内容
  - Likeモデルの作成（User-Post間の関連）
  - いいね/いいね取消の実装
  - いいね数の表示
  - Ajax対応のいいねボタン
  - 重複いいね防止（ユニーク制約）
  - RSpec テスト作成（Model/Request/System）
  - FactoryBot設定

  完了条件 ✅
  - ユーザーが投稿にいいねできる ✅
  - いいね状態とカウントが適切に表示される ✅
  - Ajax（非同期）で動作する ✅
  - 230+テスト継続成功 ✅

  ---------------------------
  📋 Task 1: branch.mdの更新（いいね機能仕様確定）

  - いいね機能の対象を投稿のみに確定
  - Task分解の詳細化
  - CLAUDE.mdとの整合性確保

  📋 Task 2: Likeモデルの作成（Postのみ）

  - rails generate model Like user:references post:references実行
  - シンプルなUser-Post関連（Polymorphicは使用しない）
  - マイグレーションファイル生成確認

  📋 Task 3: マイグレーションファイルの調整

  - ユニーク制約追加（user_id + post_id）
  - インデックス設定の最適化
  - created_at, updated_atの設定確認

  📋 Task 4: Likeモデルにバリデーション追加

  - user_id, post_idの必須バリデーション
  - ユニークネスバリデーション実装
  - モデルテスト用基本メソッド準備

  📋 Task 5: Postモデルにいいね関連を追加

  - has_many :likes, dependent: :destroyの追加
  - いいね数取得メソッド実装（likes_count）
  - いいね状態確認メソッド実装（liked_by?）

  📋 Task 6: Userモデルにいいね関連を追加

  - has_many :likes, dependent: :destroyの追加
  - いいねした投稿取得メソッド実装（liked_posts）

  📋 Task 7: マイグレーション実行とテスト

  - rails db:migrateでマイグレーション実行
  - schema.rbの確認
  - コンソールでの基本動作確認

  📋 Task 8: いいねコントローラーの作成

  - LikesControllerの作成
  - create, destroyアクション実装
  - 認証必須設定（before_action）

  📋 Task 9: ルーティングの追加

  - config/routes.rbにいいね関連ルート追加
  - posts/:post_id/likes（RESTfulなネスト構造）
  - Ajax対応の設定

  📋 Task 10: いいねボタンのView実装（Ajax対応）

  - _like_button.html.erbパーシャル作成
  - いいね状態に応じたボタン表示切り替え
  - Stimulus又はTurboでのAjax機能実装
  - 投稿詳細・一覧へのボタン配置

  📋 Task 11: ユニットテストの作成

  - spec/models/like_spec.rbの作成（バリデーション、アソシエーション）
  - spec/models/post_spec.rbの更新（いいね関連メソッド）
  - spec/models/user_spec.rbの更新（いいね関連メソッド）
  - FactoryBot設定（spec/factories/likes.rb）

  ✅ Task 12: Systemテストの作成

  - spec/system/likes_spec.rbの作成
  - いいねボタンクリックの統合テスト
  - Ajax動作確認テスト
  - いいね数表示確認テスト
  ---------------------------

  🎉 **09_like_#11ブランチ完全完成！**

  **実装完了日**: 2025-09-08
  **実装内容**: いいね機能の完全実装
  - Likeモデル（User-Post関連、ユニーク制約）
  - LikesController（Turbo Stream + HTML対応）
  - いいねボタンUI（投稿詳細・一覧配置）
  - 包括的テスト（Model/Request/System、約40テスト追加）

  **技術選択**:
  - シンプルなhas_many関連（Polymorphic不使用）
  - Turbo Stream活用（JSON API削除、シンプル化）
  - has_many through設計（統一的メソッドインターフェース）

  **テスト結果**: 230+テスト全て成功
  ---------------------------

  9. 10_sns_#12 ✅ 完成

  Issue: SNS連携機能の実装（いいね機能完了後）

  概要
  X（旧Twitter）シェア機能の実装

  実装内容
  - X投稿ボタンの実装（Web Intents API使用）
  - 投稿者判定による動的メッセージ切り替え
  - 基本的なOGPメタタグ設定（仮画像使用）
  - セキュリティ対策完備
  - ブラウザ動作確認完了

  完了条件 ✅
  - 投稿をXにシェアできる ✅
  - 投稿者判定によるメッセージ切り替え ✅
  - 基本的なOGP対応 ✅
  - セキュリティ対策完備 ✅

  ---------------------------
  ✅ Task 1: X投稿ボタンヘルパーメソッドの実装 (完成)

  - ApplicationHelperにx_share_buttonメソッド追加
  - X Web Intents APIのURL生成
  - シェア用テキスト生成（投稿者判定機能付き）
  - Xブランドカラー（黒基調）のボタンデザイン

  ✅ Task 2: 投稿詳細ページにX投稿ボタンを配置 (完成)

  - posts/show.html.erbにシェアボタン追加
  - いいねボタンと並べた配置
  - 投稿者判定による表示切り替え（「おすすめ」／「気になる」）

  ✅ Task 3: 基本的なOGPメタタグ設定 (完成)

  - application.html.erbにOGPメタタグ追加
  - 投稿詳細ページでの動的メタタグ設定
  - 既存アイコン（icon.png）を仮OGP画像として設定

  ✅ Task 4: セキュリティ対策・最適化 (完成)

  - CGI.escapeによるURL Safe処理
  - rel="noopener noreferrer"設定
  - data-turbo="false"設定

  ✅ Task 5: 動作確認とリファクタリング (完成)

  - ブラウザでのシェア動作確認完了
  - 投稿者判定による動的表示確認
  - Rails 7準拠のクリーンな実装

  **🎉 実装完了日**: 2025-09-09
  **技術選択**: Web Intents API（シンプル・確実）
  **実装方針**: Rails標準のヘルパーメソッド + セキュリティ対策
  ---------------------------

  10. 11_responsive-design_#13

  Issue: レスポンシブデザイン最適化

  概要
  モバイルファーストのレスポンシブデザイン最適化

  実装内容
  - 検索フォームのトグル機能（モバイル対応）
  - ボタンテキスト折り返し問題の解決
  - モバイルタッチ操作の最適化
  - 投稿カードレイアウトの微調整
  - 既存UI基盤を活用した段階的改善

  完了条件
  - 検索フォームがモバイルでトグル表示される
  - ボタンテキストが折り返さない
  - タッチ操作が最適化されている
  - 全デバイスで適切に表示される

  ---------------------------
  ✅ Task 1: 検索フォームのトグル機能実装 (完成)

  - 検索アイコンボタンの追加 ✅
  - Stimulusコントローラー（search-toggle）の作成 ✅
  - app/javascript/controllers/index.js への登録 ✅
  - モバイルでフォーム表示/非表示切り替え機能 ✅
  - アニメーション付きのスムーズな表示切り替え ✅
  - レスポンシブ対応（640px以下でトグル、以上で常時表示） ✅
  - アクセシビリティ対応（aria-expanded、aria-controls） ✅

  📋 Task 2: ボタンテキスト折り返し問題の解決

  - ログインボタンのテキスト調整
  - 投稿ボタンのレスポンシブ対応
  - 検索ボタンのモバイル対応
  - いいね・Xシェアボタンの折り返し防止
  - 文字サイズとボタン幅の最適化

  📋 Task 3: モバイルタッチ操作の最適化

  - 最小タッチサイズ44px確保
  - ボタン間隔の調整（8px以上確保）
  - タッチフレンドリーなインタラクション
  - ホバー効果のタッチ対応調整

  📋 Task 4: 投稿カードレイアウトの微調整

  - モバイルでのカード内余白調整
  - テキスト行間・フォントサイズ最適化
  - 画像アスペクト比の調整
  - カード間隔のレスポンシブ対応

  📋 Task 5: 動作確認とテスト

  - 各デバイスサイズでの表示確認
  - タッチ操作の動作確認
  - 既存機能の回帰テスト実行
  - パフォーマンステスト
  ---------------------------


  11. feature/advanced-image-features

  Issue: 高度な画像機能の実装

  概要
  OGP画像取得やバックグラウンド処理など、拡張画像機能

  実装内容
  - OGP画像自動取得機能（通販リンクから商品画像取得）
  - バックグラウンド画像取得（Active Job使用）
  - 画像キャッシュ機能
  - 外部API連携（Amazon API、楽天API）
  - 画像最適化・WebP対応

  完了条件
  - 通販リンクから画像を自動取得できる
  - バックグラウンド処理が正常動作する
  - パフォーマンスが向上している

  12. feature/deployment

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
