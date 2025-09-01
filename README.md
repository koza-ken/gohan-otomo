# 🍚 ご飯のお供（gohan-otomo）

## 概要

ユーザーが「ご飯のお供」を投稿・共有できるWebアプリケーションです。
お米がテーマの温かいデザインで、初回アクセス時には稲穂からご飯までのアニメーションでユーザーを迎えます。

## 実装済み機能

- **ウェルカムアニメーション**: 稲穂 → コンバイン → 炊き立てご飯のアニメーション
- **ユーザー認証**: Deviseによる登録・ログイン（日本語対応フォーム）
- **米テーマデザイン**: オレンジを基調とした統一されたUI
- **レスポンシブ対応**: モバイル・タブレット・デスクトップ対応
- **セッション管理**: 初回のみアニメーション表示、スキップ機能

## 開発環境セットアップ

```bash
# コンテナ起動
docker compose up

# ブラウザでアクセス
http://localhost:3000
```

## 予定機能

### ユーザー機能
- **プロフィール管理**: 好きな食べ物・嫌いな食べ物の設定
- **プロフィール公開**: 他のユーザーからの閲覧機能

### 投稿機能（ハイブリッド画像方式）
- **おすすめ投稿**: 名前、おすすめポイント、通販リンク、画像
- **食べてみた投稿**: 実際に食べた写真、感想、評価点

### 画像取得システム
1. ユーザー画像添付 → その画像を使用
2. 通販リンクから自動取得（Amazon API、楽天API、Open Graph）
3. プレースホルダー画像表示

### その他
- **投稿一覧表示**: 掲示板形式、タイプ別フィルター
- **いいね機能**: 投稿へのリアクション
- **SNS連携**: X（旧Twitter）シェア

## 技術スタック

- **バックエンド**: Ruby on Rails 7.2
- **認証**: Devise
- **フロントエンド**: TailwindCSS v4 + Hotwire (Turbo/Stimulus)
- **テンプレート**: ERB（Rails標準）
- **テストフレームワーク**: RSpec + FactoryBot
- **コード品質**: Rubocop + Brakeman
- **データベース**: PostgreSQL
- **開発環境**: Docker
- **デプロイ**: Render

## データベース設計（予定）

### Users
- id, display_name, email, password_digest
- favorite_foods, disliked_foods
- created_at, updated_at

### Posts（STI）
- id, user_id, type (RecommendPost / ReportPost)
- title, description, link, image_url
- created_at, updated_at

### Likes
- id, user_id, post_id, created_at, updated_at

## 開発・テストコマンド

```bash
# テスト実行
docker compose exec web bundle exec rspec

# コードチェック
docker compose exec web bundle exec rubocop
docker compose exec web bundle exec brakeman

# データベース関連
docker compose exec web rails db:migrate
docker compose exec web rails db:seed
```

詳細な開発ガイドは [CLAUDE.md](./CLAUDE.md) を参照してください。
