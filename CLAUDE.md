# 🍚 ご飯のお供投稿アプリ（gohan-otomo）

## プロジェクト概要

ユーザーが「ご飯のお供」や「おかず」を投稿・共有できるアプリです。
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
- **テンプレートエンジン**: Haml (Hamlit)
- **テストフレームワーク**: RSpec + FactoryBot + Faker
- **コード品質**: Rubocop + Brakeman
- **開発ツール**: Better Errors + Ruby LSP
- **画像管理**: Active Storage + S3などクラウドストレージ
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
- **おすすめ投稿 (RecommendPost)**: 名前、おすすめポイント、通販リンク、単体画像
- **食べてみた投稿 (ReportPost)**: 実際に食べた写真、感想、評価点

### 画像取得の流れ
1. ユーザーが画像を添付 → その画像を使用
2. 添付がない場合、通販リンクがある場合 → 外部サイトの画像を引用（Amazon Product API、楽天商品API、Open Graph画像など）
3. どちらもない場合 → サンプル画像やプレースホルダーを表示

### その他の機能
- 投稿一覧表示（掲示板形式）
- 投稿タイプ別にフィルター可能
- いいね機能
- SNS連携（X（旧Twitter）にシェア）

## データベース設計（初期案）

### Users
- id, username, email, password_digest
- favorite_foods (好きな食べ物)
- disliked_foods (嫌いな食べ物)
- created_at, updated_at

### Posts（STIで管理）
- id, user_id, type (RecommendPost / ReportPost)
- title, description, link, image_url
- created_at, updated_at

### Likes
- id, user_id, post_id, created_at, updated_at

## 今後の開発予定

### 実装予定機能
1. 通販リンクからの自動画像取得方法（Amazon API, 楽天API, Open Graphなど）
2. 投稿内容のSNSシェア機能（X連携）
3. モバイル対応・レスポンシブデザインの最適化
4. SEOやSNSシェア対応
5. 投稿タイプごとにフォームや表示を分けるUI/UX設計
6. プロフィール情報（好き・嫌いな食べ物）の表示・編集UI
7. 投稿一覧・ユーザーページで他ユーザーの好みを確認できる機能

## 開発環境の設定ファイル

### 追加済みの設定
- **RSpec設定**: `spec/rails_helper.rb`, `spec/spec_helper.rb`
- **FactoryBot設定**: `spec/support/factory_bot.rb`
- **Better Errors設定**: `config/initializers/better_errors.rb`
- **Rubocop設定**: `.rubocop.yml`
- **Docker設定**: `compose.yml`, `Dockerfile.dev`

## 開発時の注意事項

- モバイルファースト設計を心がける
- 投稿タイプ（おすすめ/食べてみた）による機能差分を適切に実装
- 画像取得のハイブリッド方式を適切に実装
- プロフィール公開機能の実装
- テストを書く際はRSpec + FactoryBotを活用する
- ERBではなくHamlでビューを作成する

## Claude Codeでの開発ルール

### コード修正時のルール
コードを修正する際は、必ず以下の形式で理由を明示してから修正を提示する：

```
## 修正の目的と理由
**目的**: 何を実現するための修正か
**理由**: なぜこの修正が必要か
**方針**: どのようなアプローチで修正するか
```

### テストコード作成のルール
機能追加や修正を行う際は、必ず以下を実施する：

1. **新機能追加時**
   - モデル、コントローラー、サービスクラスのRSpecテストを作成
   - FactoryBotでテストデータを定義
   - 正常系・異常系の両方をテスト

2. **既存機能修正時**
   - 影響範囲のテストを確認・修正
   - 新しい仕様に合わせてテストを更新
   - リグレッションテストの追加

3. **テスト実行**
   - コード修正後は必ず `docker compose exec web bundle exec rspec` でテスト実行
   - 失敗したテストがある場合は修正完了まで続行

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

# 特定のファイルのテスト実行
docker compose exec web bundle exec rspec spec/models/user_spec.rb

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