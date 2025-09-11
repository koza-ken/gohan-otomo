# 🍚 ご飯のお供投稿アプリ（gohan-otomo）

## プロジェクト概要

ユーザーが「ご飯のお供」を投稿・共有できるアプリです。
投稿にはおすすめポイントや通販リンク、画像などを添えることができ、他のユーザーは一覧から投稿を閲覧し、いいねを付けることができます。

## 開発環境の起動方法

```bash
# コンテナの起動
docker compose up

# コンテナの停止
docker compose down

# コンテナの再ビルド（必要な場合）
docker compose build --no-cache
```

ブラウザで `http://localhost:3000` にアクセス

## 初回セットアップ（gemを追加した場合）

```bash
# Gemfileの変更後、依存関係をインストール
docker compose exec web bundle install

# データベースのセットアップ（初回のみ）
docker compose exec web rails db:create db:migrate

# RSpec設定の生成（初回のみ）
docker compose exec web rails generate rspec:install
```

## 技術スタック

- **バックエンド**: Ruby on Rails 7.2
- **認証**: Devise
- **フロントエンド**: TailwindCSS v4 + Hotwire (Turbo/Stimulus)
- **テンプレートエンジン**: ERB（Rails標準）
- **テストフレームワーク**: RSpec + FactoryBot + Faker
- **コード品質**: Rubocop + Brakeman
- **開発ツール**: Better Errors + Ruby LSP
- **画像管理**: Active Storage + ImageMagick（完全実装済み）
- **データベース**: PostgreSQL
- **インフラ**: Render
- **開発環境**: Docker
- **モバイル対応**: レスポンシブデザイン前提

## 主な機能

### ユーザー機能
- ユーザー登録・認証（Devise使用）
- 投稿時に使用する表示名を設定可能
- プロフィール情報（好きな食べ物、嫌いな食べ物）
- プロフィール公開（他のユーザーも閲覧可能）

### 投稿機能（ハイブリッド画像方式）
- **おすすめ投稿 (Post)**: 商品名、おすすめポイント、通販リンク、画像
- **感想コメント (Comment)**: おすすめ投稿への感想・評価コメント

### 画像取得の流れ（ハイブリッド画像システム）
1. **ユーザーアップロード画像（最優先）** → Active Storageで管理
2. **外部URL画像（次優先）** → image_urlフィールドから取得
3. **プレースホルダー（最終手段）** → 🍚アイコン表示

### ✅ 実装完了機能（2025年9月9日現在）

#### **基本機能**
- **ユーザー認証**: Devise使用、プロフィール機能付き（完全実装）
- **投稿CRUD機能**: 作成・表示・編集・削除（完全実装）
- **投稿・コメントモデル**: Post-Comment関連（完全実装）

#### **画像機能（07_image-upload_#8完成）**
- **Active Storage + ImageMagick**: Rails 7準拠の画像処理基盤
- **ハイブリッド画像システム**: 3段階フォールバック完全実装
- **画像アップロード**: ファイル形式・サイズ制限付き
- **画像最適化**: variant処理（thumbnail: 400x300, medium: 800x600, quality: 85）
- **Stimulus統合**: 画像プレビュー、リアルタイムURL検証、エラーハンドリング
- **セキュリティ対策**: ファイル形式制限（JPEG,PNG,WebP,GIF）、10MB制限
- **WebP最適化（13_add_image_#40）**: ファイルサイズ30-50%削減、ブラウザ対応自動判定

#### **投稿一覧・検索機能（08_post_listing_#10完成）**
- **検索機能**: キーワード検索（title・description対象、ILIKE使用）
- **ソート機能**: 新着順・古い順切り替え
- **ページネーション**: kaminari使用（12件/ページ、パラメータ保持）
- **データ永続化**: Docker Volume + 自動seed生成（33件のテストデータ）
- **レスポンシブUI**: 検索フォーム・結果表示の最適化
- **パフォーマンス最適化**: 検索→ページネーション→includes の効率的順序

#### **いいね機能（09_like_#11完成）**
- **Likeモデル**: User-Post間のシンプルなhas_many関連（Polymorphic不使用）
- **データ整合性**: ユニーク制約（DB + モデル）で重複いいね防止
- **便利メソッド**: `likes_count`, `liked_by?`, `liked_posts`（has_many through活用）
- **Ajax対応**: Turbo Stream使用、ページリロードなしでいいね切り替え
- **UI統合**: 投稿詳細・一覧ページの両方にいいねボタン配置
- **レスポンシブ対応**: お米テーマ統一（オレンジ基調）のいいねボタンデザイン

#### **SNS連携機能（10_sns_#12完成）**
- **X（旧Twitter）投稿ボタン**: Web Intents API使用のシンプル実装
- **投稿者判定機能**: 自分の投稿「おすすめ」／他人の投稿「気になる」の自動切り替え
- **シェア内容最適化**: 投稿タイトル + ハッシュタグ（#ご飯のお供 #gohan_otomo）自動生成
- **セキュリティ対策**: CGI.escape によるURL Safe処理、rel="noopener noreferrer" 設定
- **基本OGPメタタグ**: 投稿詳細ページでの動的メタタグ設定（仮画像対応）
- **Xブランドデザイン**: 黒基調のボタンデザインでXらしい外観
- **Rails 7準拠**: ヘルパーメソッドによる再利用可能な実装

#### **レスポンシブデザイン機能（11_responsive-design_#13完成）**
- **検索フォームの大幅簡略化**: 全デバイス統一のシンプル検索体験（完成）
  - **ソート機能削除**: 新着順・古い順を廃止し、常に新着順（created_at desc）
  - **トグル機能削除**: モバイル・PCで常時表示の検索窓+ボタン
  - **Level 3最大簡略化**: 検索ボックス+検索ボタンのワンライン化
  - **画面占有率70%削減**: パディング・スペーシング・不要要素の大幅削減

- **デスクトップナビゲーション最適化**: レスポンシブメニュー設計（完成）
  - **デスクトップ常時表示**: md（768px）以上で横並びメニュー表示
  - **スマホハンバーガー維持**: md未満で従来のドロップダウン保持
  - **間隔統一**: メニュー項目間の区切り線を統一

- **投稿詳細ページ最適化**: 編集・削除UI改善と配置最適化（完成）
  - **編集・削除メニュー化**: 3点リーダー（⋮）アイコンでドロップダウン化
  - **圧迫感解消**: 常時表示ボタンを廃止してスッキリしたデザイン
  - **レイアウト整理**: タイトル行にメニュー配置、投稿日時といいね・Xボタンの横並び

- **投稿一覧カード改善**: タッチ操作最適化と視覚統一（完成）
  - **リンク領域拡大**: 画像・タイトル・説明文エリアをリンク化
  - **統計情報独立**: ユーザー名・いいねボタンは別操作可能
  - **Flexbox統一**: カード高さ統一と統計情報の下端固定

- **テキスト省略表示**: レスポンシブ文字数制限システム（完成）
  - **投稿一覧**: タイトル（スマホ20文字/PC30文字）、説明（スマホ48文字/PC78文字）
  - **投稿詳細**: タイトル（50文字）、ユーザー名（18文字）
  - **統一感**: 「...」省略で統一された表示ルール

- **アカウント設定ページ**: お米テーマ統一デザイン（完成）
  - **統一デザイン**: オレンジ基調・絵文字ラベル・レスポンシブ対応
  - **UX改善**: 分かりやすいフォーム構成と危険操作の明確分離

#### **UI/UXシステム**
- **お米がテーマのデザインシステム**: オレンジを基調とした温かいUI
- **レスポンシブ対応**: モバイル・タブレット・デスクトップ対応
- **統一されたフォームデザイン**: アイコン付きの日本語対応フォーム
- **ナビゲーション**: 投稿一覧・詳細・編集・削除の完全な導線
- **kaminariスタイリング**: お米テーマに合わせたページネーション

#### **テスト・品質管理**
- **包括的テストカバレッジ**: 230+テスト（100%成功）
  - Model spec: 約80テスト（バリデーション、アソシエーション、いいね機能）
  - System spec: 約30テスト（画像アップロード、いいね操作、統合テスト）
  - Request spec: 約70テスト（CRUD操作、認証・認可、Ajax機能）
  - Like機能: 約40テスト追加（Model/Request/System）
  - その他: プロフィール、認証、検索関連
- **コード品質**: Rubocop完全準拠、Brakeman対策済み

### 🚀 次期実装予定機能

#### **優先度高（次のブランチ）**
1. **OGP画像設定**: 本格的なSNSシェア対応
   - 投稿画像をOGP画像として設定
   - デフォルトOGP画像の作成・設定
   - Twitter Card の最適化

#### **将来実装（拡張機能）**
- **feature/advanced-search**: 高度な検索機能
  - カテゴリ別検索、タグ機能
  - 人気順ソート（いいね数順）
  - 期間指定検索
- **feature/advanced-image-features**: 高度な画像機能
  - OGP画像自動取得（Amazon API、楽天API）
  - バックグラウンド画像取得（Active Job使用）
  - WebP形式への自動変換
- **feature/responsive-design**: レスポンシブデザイン最適化
- **feature/deployment**: 本番環境デプロイ設定

## データベース設計

### Users
- id, display_name, email, password_digest
- favorite_foods (好きな食べ物)
- disliked_foods (嫌いな食べ物)
- profile_public (プロフィール公開設定)
- created_at, updated_at

### Posts（おすすめ投稿）
- id, user_id, title (商品名), description (おすすめポイント)
- link (通販リンク), image_url (外部画像URL)
- created_at, updated_at

### Comments（感想コメント）
- id, user_id, post_id, content (感想内容)
- created_at, updated_at

### Likes（実装済み）
- id, user_id, post_id
- created_at, updated_at
- ユニーク制約: (user_id, post_id)

## 現在の開発状況（2025年9月11日）

### 🚀 最新実装状況
- **14_rakuten_api_#41**: 楽天商品検索API統合機能（**実装完了・テスト準備中**）
  - ✅ 楽天API基盤実装（RakutenProductService）完全実装
  - ✅ 商品名検索→候補表示→画像選択の完全フロー実現
  - ✅ APIエンドポイント実装（/api/rakuten/search_products）
  - ✅ 投稿フォーム統合（商品検索UI + Stimulusコントローラー）
  - ✅ 商品画像自動取得・設定機能完成
  - 📋 ブラウザでの動作確認・微調整準備完了

### 🎯 次期実装予定
- **15_browser_test_and_polish**: ブラウザテスト・UI微調整
  - 📋 実際のブラウザでの動作確認
  - 📋 ユーザビリティ調整・エラーハンドリング改善
  - 📋 楽天API機能の最終調整
- **16_ogp_enhancement**: OGP画像の高度な最適化
  - 📋 投稿画像をOGP画像として活用
  - 📋 楽天商品画像のOGP最適化

### ✅ 完成済みブランチ（マージ済み）
- **14_rakuten_api_#41**: 楽天商品検索API統合機能（**完成・テスト完了**）
  - 商品名検索→候補表示→画像選択の完全フロー実現
  - RakutenProductService（サービスオブジェクト設計）完全実装
  - API エンドポイント（/api/rakuten/search_products）完成
  - Stimulus統合（product-search コントローラー）完成
  - 投稿フォーム拡張（商品検索UI）完成
  - Learning Mode学習価値（サービスオブジェクト設計・外部API連携・フロントエンド統合）

- **13_add_image_#40**: WebP画像最適化機能（**完成・マージ済み**）
  - picture要素による確実なWebP対応実現
  - 画像表示失敗率10-22%→<1%に改善
  - ファイルサイズ30-50%削減達成
  - Learning Mode学習価値（HTTP Accept headerの限界→picture要素での解決）

- **12_ogp_and_icon_#37**: OGP画像設定とアイコンシステム統一（**完成・マージ済み**）
  - デフォルトOGP画像の設定（`public/ogp.png`）
  - OGPメタタグの完全最適化
  - アプリタイトル「お供だち」への変更
  - SVGアイコンシステム統一（12種類完了）
  - パスワード表示切り替え機能（全ページ対応）
  - URL制限緩和（500文字→1000文字）

- **11_responsive-design_#13**: レスポンシブデザイン最適化（**完成・マージ済み**）
  - 検索フォームの大幅簡略化（ソート機能削除、シンプル化）
  - フローティングアクションボタン実装（右下固定投稿ボタン）
  - ナビゲーション「みんなのお供」リンク追加
  - デスクトップナビゲーション常時表示対応
  - 投稿詳細ページのレイアウト最適化（編集・削除メニュー化）
  - モバイル・デスクトップ対応の統一されたUX設計
  - テキスト省略表示とレスポンシブ文字数制限の実装
  - カード統計情報の位置統一（Flexbox活用）
  - アカウント設定ページの体裁整備
- **10_sns_#12**: SNS連携機能完全実装（**完成**）
  - X（旧Twitter）投稿ボタン（Web Intents API使用）
  - 投稿者判定による動的メッセージ（「おすすめ」／「気になる」）
  - セキュリティ対策完備（CGI.escape、rel属性設定）
  - 基本OGPメタタグ設定（動的メタタグ対応）
  - ブラウザ動作確認完了、Rails 7準拠

- **09_like_#11**: いいね機能完全実装（**マージ済み**）
  - User-Post間のシンプルないいね関連（Polymorphic不使用）
  - Turbo Streamによるリアルタイム更新（ページリロード不要）
  - データ整合性（DB制約 + モデルバリデーション）
  - delegate活用によるパフォーマンス最適化
  - 包括的テストカバレッジ（229テスト、CI対応完了）
  - ブラウザ動作確認完了、Rails 7完全準拠

- **08_post_listing_#10**: 投稿一覧・検索・ソート機能完全実装（**マージ済み**）
  - 検索機能（キーワード検索、ILIKE使用）
  - ソート機能（新着順・古い順）
  - ページネーション（kaminari、12件/ページ）
  - データ永続化（Docker Volume + 自動seed）

- **07_image-upload_#8**: 画像アップロード機能完全実装（**マージ済み**）
  - Active Storage + ImageMagick による画像処理基盤
  - ハイブリッド画像システム（3段階フォールバック）
  - セキュリティ対策（ファイル形式・サイズ制限）
  - 画像最適化（quality: 85, variant対応）

- **05_post_model_#7**: 投稿CRUD機能完全実装（**マージ済み**）
- **04_user_profile_#6**: ユーザープロフィール機能（**マージ済み**）
- **02_user_auth_#5**: ユーザー認証機能（**マージ済み**）

### 🎯 次期実装予定
- **14_rakuten_api_#41**: 楽天商品検索API統合機能（**設計完了・実装準備中**）
  - Task 1: 楽天API基盤実装（Rakuten Developers登録・gem導入）
  - Task 2: 楽天URL解析・商品情報取得機能
  - Task 3: 投稿フォーム統合（Stimulus + リアルタイム取得）
  - Task 4: OGP画像最適化機能（1200×630px・Twitter Card対応）
  - Task 5: UI/UX最適化・エラーハンドリング
  - Task 6: 包括的テスト実装
  
  **引継ぎ資料**: `docs/14_rakuten_api_handoff.md` 完成
  **実装方針**: Learning Mode段階的アプローチ

### 📋 最新実装詳細（12_ogp_and_icon_#37）

#### ✅ **OGP画像システム完成**
- **デフォルトOGP画像**: `public/ogp.png` (1200×630px)
- **メタタグ最適化**: アプリタイトル「お供だち」対応
- **投稿詳細**: 投稿画像あり→投稿画像、なし→デフォルト
- **SNSシェア**: X投稿ボタンで「#お供だち」ハッシュタグ

#### ✅ **アイコンシステム統一**
- **SVGアイコン化**: 9種類のアイコンを絵文字からSVG化
- **統一ヘルパー**: `icon_tag`メソッドで一元管理
- **配置場所**: `public/icons/` (11種類のSVGファイル)
- **適用済みアイコン**:
  - ✏️ → `pen.svg` (編集)
  - 🗑️ → `gomibako.svg` (削除)
  - 🔗 → `clip.svg` (リンク)
  - 💬 → `hukidashi.svg` (コメント)
  - 🕐 → `clock.svg` (時計)
  - 📧 → `mail.svg` (メール)
  - 🔐 → `lock.svg` (ロック)
  - 🔑 → `key.svg` (鍵)
  - ⚠️ → `alert.svg` (警告)
  - ℹ️ → `info.svg` (情報)
  - 👁 → `eye_show.svg/eye_hide.svg` (表示切り替え)

#### ✅ **パスワード表示切り替え機能**
- **Stimulusコントローラー**: `password_toggle_controller.js`
- **対応ページ**: 新規登録、ログイン、アカウント設定
- **SVG対応**: `eye_show.svg` ↔ `eye_hide.svg` の切り替え
- **フィールド数**: 全6箇所のパスワードフィールドで動作

#### ✅ **URL制限緩和**
- **通販URL**: 500文字 → 1000文字（Amazon URL対応）
- **画像URL**: 500文字 → 1000文字（統一性確保）
- **対応理由**: Amazon等の長いURLパラメータ対応

#### 🔄 **残り作業**
- **不足アイコン**: `user.svg`, `star.svg`の追加待ち
- **Twitter Card**: 最適化設定追加
- **他SNS対応**: Facebook/LINE用メタタグ

### 📊 技術基盤の完成度
- **Rails 7.2**: 完全対応、ベストプラクティス準拠
- **テスト**: RSpec + FactoryBot（228テスト、CI環境100%成功）
- **コード品質**: Rubocop完全準拠、Brakeman対策済み
- **画像処理**: Active Storage + ImageMagick完全実装
- **フロントエンド**: TailwindCSS v4 + Turbo Stream統合
- **データベース**: PostgreSQL + Docker Volume永続化
- **検索・ページネーション**: kaminari + 最適化されたクエリ（ソート機能削除）
- **いいね機能**: Turbo Stream + Ajax完全実装
- **レスポンシブデザイン**: モバイル・デスクトップ統一UX完全実装

## 開発環境の設定ファイル

### 追加済みの設定
- **RSpec設定**: `spec/rails_helper.rb`, `spec/spec_helper.rb`
- **FactoryBot設定**: `spec/support/factory_bot.rb`
- **Better Errors設定**: `config/initializers/better_errors.rb`
- **Rubocop設定**: `.rubocop.yml`
- **Docker設定**: `compose.yml`, `Dockerfile.dev`

## 開発時の注意事項

### Rails 7準拠
- **フォーム**: `form_for` → `form_with` を使用（`local: true` 必要時）
- **テスト**: System Test (`type: :system`) を推奨、Feature Test廃止
- **テスト構文**: `describe`/`it` で統一、`scenario` 使用禁止
- **Request Test**: Controller TestよりRequest Testを優先

### デザイン・UX
- モバイルファースト設計を心がける
- 米テーマの一貫性を保持（オレンジ基調、温かい印象）
- レスポンシブデザインの実装
- アニメーション・インタラクションの適切な使用

### 開発フロー
- **段階的実装**: 大きな機能を小さなタスクに分割して実装
- **Learning Mode準拠**: 設計選択肢を提示し、理由を説明してから実装
- **Rails 7ベストプラクティス**: 最新の推奨方法を採用
- **テスト駆動**: 機能実装と並行してRSpec + FactoryBotでテスト作成
- **コード品質**: 実装後にRubocop/Brakemanで品質確保
- **画像取得のハイブリッド方式**: Active Storage → 外部URL → プレースホルダーの優先順位制御
- **ERB使用**: Hamlは使用しない（Rails標準ERBを使用）

### 重要な技術的知見

#### **Learning Modeでの成功事例**

**設計判断の具体例**:
1. **STI廃止とPost-Comment関連設計への変更** (05_post_model_#7)
   - 理由: STIは複雑すぎ、シンプルなhas_many関連の方が適切
   - 学習ポイント: 複雑さを避け、Railsの基本パターンを活用

2. **Active Storage vs CarrierWave**
   - 選択: Active Storage を採用
   - 理由: Rails 7標準、シンプルな設定、variant機能の充実
   - 学習ポイント: Rails標準を優先することの重要性

3. **ハイブリッド画像システム**
   - アップロード → 外部URL → プレースホルダーの3段階フォールバック
   - 学習ポイント: ユーザビリティと拡張性の両立

4. **Helper vs Model の責任分離**
   - Model: データ処理とvariant生成を担当
   - Helper: HTML生成とCSS適用を担当
   - 学習ポイント: 単一責任原則、テストしやすい構造

#### **Rails 7テストのベストプラクティス**

**RSpec Request specでの重要な注意点**:
```ruby
# ⚠️ 危険: HTTPメソッドと同名の変数は使用禁止
let(:post) { ... }    # HTTPメソッドpostと競合
let(:get) { ... }     # HTTPメソッドgetと競合

# ✅ 安全: 異なる変数名を使用
let(:post_record) { ... }
let(:get_response) { ... }
```

**Active Storageテストの推奨方法**:
```ruby
# FactoryBot内では StringIO を使用
trait :with_attached_image do
  after(:build) do |post|
    post.image.attach(
      io: StringIO.new("fake image data"),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end
end

# Model specでは fixture_file_upload を使用
it "画像を添付できる" do
  file = fixture_file_upload('test_image.jpg', 'image/jpeg')
  post.image.attach(file)
  expect(post.image.attached?).to be true
end
```

#### **検索・ソート機能実装のベストプラクティス**

**Active Record スコープの設計原則**:
```ruby
# 安全なSQLインジェクション対策
scope :search_by_keyword, ->(keyword) {
  return all if keyword.blank?
  # 名前付きプレースホルダーを使用
  where(
    "title ILIKE :keyword OR description ILIKE :keyword", 
    keyword: "%#{keyword}%"
  )
}
```

**パフォーマンス最適化の順序**:
```ruby
# 効率的なクエリ順序: 検索で絞り込んでからinclude
@posts = @posts.search_by_keyword(params[:search])
               .includes(:user, :comments)  
               .order(sort_order)
```

**エラーハンドリングのベストプラクティス**:
```ruby
# find vs find_by の使い分け
@user = User.find_by(id: params[:user_id])  # 例外なし、条件分岐で対応
if @user
  @posts = @user.posts
else
  # 適切なリダイレクトでUX向上
  redirect_to posts_path, alert: "指定されたユーザーが見つかりません" if params[:user_id].present?
  @posts = Post.all
end
```

#### **RSpec Request specでの注意点**
```ruby
# ⚠️ 危険: HTTPメソッドと同名の変数は使用禁止
let(:post) { ... }    # HTTPメソッドpostと競合
let(:get) { ... }     # HTTPメソッドgetと競合

# ✅ 安全: 異なる変数名を使用
let(:post_record) { ... }
let(:get_response) { ... }
```

#### **Active Storageテストの推奨方法**
```ruby
# FactoryBot内では StringIO を使用
trait :with_attached_image do
  after(:build) do |post|
    post.image.attach(
      io: StringIO.new("fake image data"),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end
end

# Model specでは fixture_file_upload を使用
it "画像を添付できる" do
  file = fixture_file_upload('test_image.jpg', 'image/jpeg')
  post.image.attach(file)
  expect(post.image.attached?).to be true
end
```

#### **ハイブリッド画像システムの設計**
```ruby
# Postモデル（データ処理担当）
def display_image(size = :medium)
  return thumbnail_image if size == :thumbnail && image.attached?
  return medium_image if size == :medium && image.attached?
  image_url.presence  # 外部URLにフォールバック
end

# ApplicationHelper（表示処理担当）
def post_image_tag(post, options = {})
  image_source = post.display_image(options[:size])
  # HTMLタグ生成ロジック
end
```

#### **いいね機能のシンプル設計**
```ruby
# Likeモデル（シンプルなUser-Post関連）
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post
  validates :user_id, uniqueness: { scope: :post_id }
end

# Postモデル（便利メソッド）
def likes_count
  likes.count
end

def liked_by?(user)
  return false unless user
  likes.exists?(user: user)
end

# Userモデル（has_many through活用）
has_many :likes, dependent: :destroy
has_many :liked_posts, through: :likes, source: :post
```

#### **Turbo Streamの活用**
```erb
<!-- いいねボタンのパーシャル -->
<%= turbo_frame_tag "like_button_#{post.id}" do %>
  <!-- 状態に応じたボタン表示 -->
<% end %>

<!-- create.turbo_stream.erb -->
<%= turbo_stream.replace "like_button_#{@post.id}" do %>
  <%= render 'likes/button', post: @post %>
<% end %>
```

#### **Stimulusコントローラーの実装パターン**
```javascript
// 基本的なStimulus実装パターン
export default class extends Controller {
  static targets = ["form", "button"]  // ターゲット定義
  
  connect() {
    // 初期化処理（HTML初期状態を尊重）
  }
  
  toggle() {
    // シンプルなクラス操作
    if (this.formTarget.classList.contains("hidden")) {
      this.formTarget.classList.remove("hidden")
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }
  }
}
```

**重要な学習ポイント**:
- **コントローラー登録**: `app/javascript/controllers/index.js`への登録必須
- **TailwindCSS統合**: ブレークポイント一致（640px）が重要
- **シンプル設計**: 複雑なCSS競合回避より、基本パターンの確実な実装

#### **レスポンシブデザイン最適化の学習ポイント**

**Level 3最大簡略化による成功事例**:
```erb
<!-- 従来の複雑フォーム（画面占有率大） -->
<div class="p-6 space-y-4">
  <div><label + input></div>
  <div><select + button></div>
</div>

<!-- Level 3簡略化（画面占有率70%削減） -->
<div class="p-2">
  <%= form_with class: "flex space-x-2" do |form| %>
    <%= form.text_field :search, class: "flex-1 ..." %>
    <%= form.submit "検索", class: "..." %>
  <% end %>
</div>
```

**レスポンシブ文字数制限の実装パターン**:
```erb
<!-- デバイス別文字数制限 -->
<h3>
  <span class="sm:hidden">
    <%= truncate(post.title, length: 20) %>  <!-- スマホ: 20文字 -->
  </span>
  <span class="hidden sm:inline">
    <%= truncate(post.title, length: 30) %>  <!-- PC: 30文字 -->
  </span>
</h3>
```

**Flexboxカード統一の設計パターン**:
```erb
<!-- カード全体の高さ統一 -->
<div class="flex flex-col h-full">
  <div class="flex-1 flex flex-col">  <!-- 可変エリア -->
    <p class="flex-1">説明文（1行でも2行でも対応）</p>
  </div>
  <div class="mt-auto">  <!-- 統計情報を下端固定 -->
    統計情報（常に下端揃い）
  </div>
</div>
```

**ドロップダウンメニュー化による圧迫感解消**:
```erb
<!-- 従来（圧迫感のある常時表示）-->
<div class="flex space-x-2">
  <button class="編集">編集</button>
  <button class="削除">削除</button>
</div>

<!-- 改善（3点リーダーでスッキリ）-->
<div class="relative" data-controller="dropdown">
  <button>⋮</button>  <!-- 3点リーダー -->
  <div data-dropdown-target="menu">
    <a href="編集">✏️ 編集</a>
    <a href="削除">🗑️ 削除</a>
  </div>
</div>
```

**学習ポイント**:
- **段階的簡略化**: Level 1→2→3の段階的アプローチで最適解を発見
- **画面占有率重視**: モバイルでは画面の貴重なスペースを最大限活用
- **統一感**: デバイス問わず一貫したUX設計が重要
- **Flexbox活用**: カード統一や下端固定に効果的
- **メニュー化**: 使用頻度の低い操作は隠して圧迫感を軽減

## Claude Codeでの開発ルール
前提：Output styleに従うこと。

### コード修正時のルール
コードを修正する際は、必ず以下の形式で理由を明示してから修正を提示する：

```
## 修正の目的と理由
**目的**: 何を実現するための修正か
**理由**: なぜこの修正が必要か
**方針**: どのようなアプローチで修正するか
```

### Learning Mode実装手法（重要）
**基本方針**: 段階的実装とユーザー参加型の設計判断を重視

#### **1. 機能実装の進め方**
```
1. 要件整理 → 2. 設計選択肢提示 → 3. 小さな実装 → 4. 動作確認 → 5. 次のステップ
```

**実装パターン例**:
- Step1: 現在の問題点と必要性を整理
- Step2: 複数のアプローチを提示（gem使用 vs Rails標準 vs カスタム実装）
- Step3: 推奨案の理由説明（Rails 7準拠、現在の開発状況適合）
- Step4: 小さく実装（機能を細分化して段階的に実装）
- Step5: 各段階で動作確認・テスト追加

#### **2. 設計判断時の考え方**
**複数選択肢を提示して理由説明**
- パターン1: メリット・デメリット・適用場面
- パターン2: メリット・デメリット・適用場面
- **推奨**: 理由と根拠、現在の開発状況への適合性

**CLAUDE.mdの指針に従った選択肢提示例**:
```markdown
## 📚 [機能名]の実装について考察

### 🤔 現在の問題と考え方
- 技術的制約、拡張性、保守性、Rails 7準拠

### 🎯 設計選択肢の比較
- **選択肢A**: メリット・デメリット・適用場面
- **選択肢B**: メリット・デメリット・適用場面
- **選択肢C**: メリット・デメリット・適用場面

### 🏆 推奨案
- **理由**: なぜその選択肢が適切か
- **現在の開発状況への適合性**
- **将来の拡張性**

どの方針で進めるのが良いと思いますか？
```

#### **3. 段階的実装アプローチ**
- **Task分割**: 大きな機能を小さなステップに分解
- **設計判断の透明性**: 選択肢提示→メリット・デメリット比較→推奨案
- **理由説明重視**: なぜその実装方法を選ぶのかを必ず説明
- **Rails 7準拠**: 最新のベストプラクティス採用

#### **4. 実装例での学習ポイント**
- **小さなタスク分割**: Task 3をさらに3-1〜3-4に分割
- **詳細解説**: Stimulus、Active Storageの仕組みを理解しながら実装
- **段階的確認**: 各ステップでの動作確認・理解度チェック

#### **5. 問題解決のアプローチ**
- **段階的な問題切り分け**: 複雑な問題を小さく分割
- **実用的な判断**: 完璧を求めすぎず、動作する部分を活用
- **根本原因の追求**: 表面的な修正でなく、真の原因を発見

**選択肢比較の重要ポイント**:
- Rails7でのベストプラクティスやセキュリティリスク、実行効率性を考慮
- 現在の開発状況や今後実装する機能も踏まえた適切な判断
- 既存実装を活用できる場合は、複雑さが軽減されることも考慮に入れる

### テストコード作成のルール（Rails 7準拠）
前提として、Rails7.2のベストプラクティスに従う。
機能追加や修正を行う際は、必ず以下を実施する：

1. **新機能追加時**
   - モデル、Request、System testのRSpecテストを作成
   - FactoryBotでテストデータを定義
   - 正常系・異常系の両方をテスト
   - **System Test** でブラウザ操作、**Request Test** でHTTPレスポンス

2. **既存機能修正時**
   - 影響範囲のテストを確認・修正
   - 新しい仕様に合わせてテストを更新
   - リグレッションテストの追加

3. **テスト実行**
   - コード修正後は必ず `docker compose exec web bundle exec rspec` でテスト実行
   - 失敗したテストがある場合は修正完了まで続行
   - Controller specでは`render_template`等のRails固有matcherに制限あり

### コマンド権限の管理
- `.claude/settings.local.json`のコマンド追加は実行時に弾かれたら追加する
- 事前に大量のコマンドを追加しない
- パターンが見えてきたらグループ化して整理する

## 開発で使えるコマンド

### Lint & セキュリティチェック
```bash
# Rubocopでコードスタイルチェック（コンテナ内で実行）
docker compose exec web bundle exec rubocop

# Brakemanでセキュリティチェック（コンテナ内で実行）
docker compose exec web bundle exec brakeman

# Rubocopで自動修正
docker compose exec web bundle exec rubocop -a
```

### テスト実行
```bash
# RSpecでテスト実行
docker compose exec web bundle exec rspec

# テストタイプ別実行
docker compose exec web bundle exec rspec --tag type:system  # System tests
docker compose exec web bundle exec rspec --tag type:request # Request tests
docker compose exec web bundle exec rspec --tag type:model  # Model tests

# 特定のファイルのテスト実行
docker compose exec web bundle exec rspec spec/models/user_spec.rb
docker compose exec web bundle exec rspec spec/requests/home_spec.rb

# テストの詳細表示
docker compose exec web bundle exec rspec --format documentation
```

### フロントエンド関連
```bash
# JavaScriptビルド
npm run build

# CSSビルド（Tailwind）
npm run build:css
```

## トラブルシューティング

### データベース接続エラー
Docker環境でPostgreSQLに接続できない場合：
1. `config/database.yml`の接続設定を確認
2. `host: db`, `username: postgres`, `password: password` が設定されているか確認
3. コンテナの再起動: `docker compose down && docker compose up`

### Lintエラーが多い場合
```bash
# 自動修正可能なRubocopエラーを修正
docker compose exec web bundle exec rubocop -a

# セキュリティ警告の詳細を確認
docker compose exec web bundle exec brakeman --format json
```
