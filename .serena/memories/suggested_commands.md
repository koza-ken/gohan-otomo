# 開発で使用するコマンド一覧

## Docker開発環境
```bash
# 開発サーバー起動
docker compose up

# 開発サーバー停止
docker compose down

# コンテナ再ビルド
docker compose build --no-cache

# コンテナ内でコマンド実行
docker compose exec web [コマンド]
```

## データベース操作
```bash
# DB作成・マイグレーション
docker compose exec web rails db:create db:migrate

# DBリセット
docker compose exec web rails db:drop db:create db:migrate

# DBシード実行
docker compose exec web rails db:seed
```

## テスト・品質チェック
```bash
# RSpecテスト実行
docker compose exec web bundle exec rspec

# 特定ファイルのテスト
docker compose exec web bundle exec rspec spec/models/user_spec.rb

# Rubocopコードスタイルチェック
docker compose exec web bundle exec rubocop

# Rubocop自動修正
docker compose exec web bundle exec rubocop -a

# Brakemanセキュリティチェック
docker compose exec web bundle exec brakeman
```

## Rails開発
```bash
# Railsコンソール
docker compose exec web rails console

# Railsルート確認
docker compose exec web rails routes

# ジェネレータ実行
docker compose exec web rails generate model User name:string
```

## フロントエンド
```bash
# JavaScriptビルド
npm run build

# CSSビルド（TailwindCSS）
npm run build:css
```

## 依存関係管理
```bash
# Gem追加後のインストール
docker compose exec web bundle install

# Node.js依存関係インストール
yarn install
```

## よく使うLinuxコマンド
```bash
# ファイル一覧
ls -la

# ファイル検索
find . -name "*.rb" -type f

# 文字列検索
grep -r "search_term" app/

# ファイル内容表示
cat filename.rb
head -n 20 filename.rb
tail -n 20 filename.rb
```