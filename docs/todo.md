# Todo・メモ帳

## 緊急・重要タスク

### 🔥 今すぐ対応が必要
- [ ] 

### ⚡ 今日中に対応
- [ ] 

### 📅 今週中に対応
- [ ] 

## 技術的課題・検討事項

### データベース設計
- [ ] Userモデルの詳細設計確認
- [ ] Postモデルの詳細設計確認
- [ ] インデックス設計
- [ ] マイグレーション順序の検討

### パフォーマンス対策
- [ ] N+1クエリ対策の計画
- [ ] 画像最適化の詳細設計
- [ ] キャッシュ戦略の検討

### セキュリティ対策
- [ ] CSRF対策の確認
- [ ] XSS対策の確認
- [ ] ファイルアップロードのセキュリティ
- [ ] API レート制限の実装

## 機能実装メモ

### ユーザー認証（Devise）
```ruby
# 検討事項
- confirmable: メール認証を有効にするか
- lockable: アカウントロック機能
- trackable: ログイン履歴の記録
- omniauthable: SNSログイン（将来実装予定）
```

### 画像アップロード
```ruby
# Active Storage 設定メモ
- variant作成: サムネイル、中サイズ、大サイズ
- 画像形式: JPEG, PNG, WebP対応
- ファイルサイズ制限: 5MB
- 画像処理: ImageMagick or Vips
```

### STI実装
```ruby
# Post継承構造
class Post < ApplicationRecord
  # 共通属性: title, description, user_id, type
end

class RecommendPost < Post
  # 固有属性: link
end

class ReportPost < Post  
  # 固有属性: rating
end
```

## 設計上の決定事項

### 2024/XX/XX - STI vs 別テーブル
**決定**: STI（Single Table Inheritance）を採用
**理由**: 
- 投稿タイプ間で共通の属性が多い
- 一覧表示で両タイプを混在表示する必要がある
- テーブルJOINを避けてパフォーマンスを向上

### 2024/XX/XX - 画像ストレージ
**決定**: Active Storage + S3
**理由**:
- Rails標準機能で保守性が高い
- クラウドストレージでスケーラブル
- CDN連携が容易

## 気になること・調査が必要

### フロントエンド
- [ ] TailwindCSS v4の新機能調査
- [ ] Stimulus コントローラーの設計パターン
- [ ] Turbo Frame の活用方法
- [ ] モバイル対応のベストプラクティス

### バックエンド
- [ ] Rails 7.2の新機能活用
- [ ] Active Storage のパフォーマンス最適化
- [ ] Background Job の必要性
- [ ] API設計（将来のSPA化に備えて）

### インフラ・運用
- [ ] Renderのスペック・料金調査
- [ ] S3の設定とCDN連携
- [ ] 監視ツールの選定
- [ ] バックアップ戦略

## 学習・調査メモ

### 参考リンク
- [Rails 7.2 リリースノート](https://guides.rubyonrails.org/)
- [TailwindCSS v4 ドキュメント](https://tailwindcss.com/)
- [Hotwire ガイド](https://hotwire.dev/)

### 実装時の注意点
```ruby
# Rubocop 警告回避
# ハッシュの書き方統一
user_params = { name: 'test', email: 'test@example.com' }

# 長いメソッドチェーンは改行
posts = current_user
  .posts
  .includes(:user, :likes)
  .order(created_at: :desc)
```

## バグ・問題の記録

### 解決済み
- ✅ 2024/XX/XX - Docker database.yml 設定問題
  - 問題: PostgreSQL接続エラー
  - 解決: host: db の設定追加

### 未解決
- [ ] 

## アイデア・将来実装したい機能

### 短期（次のバージョン）
- [ ] ダークモード
- [ ] 投稿の下書き保存
- [ ] 画像の複数枚アップロード
- [ ] いいねの通知機能

### 中期（数バージョン後）
- [ ] フォロー・フォロワー機能  
- [ ] コメント機能
- [ ] タグ・カテゴリ機能
- [ ] 検索機能の強化

### 長期（大幅なアップデート）
- [ ] SPA化（React/Vue.js）
- [ ] ネイティブアプリ
- [ ] AI レコメンド機能
- [ ] 収益化機能

## 会議・相談メモ

### 2024/XX/XX - 設計レビュー
- 参加者: 
- 決定事項:
- アクションアイテム:

## その他メモ

### 環境構築でハマったこと
- Docker コンテナの権限問題
- Ruby LSP の設定方法
- Rubocop の設定調整

### よく使うコマンド
```bash
# Docker
docker compose up -d
docker compose exec web bundle exec rspec
docker compose exec web bundle exec rubocop

# Rails  
rails generate model User name:string
rails db:migrate
rails routes

# Git
git checkout -b feature/user-authentication
git add .
git commit -m "feat: add user authentication"
```
