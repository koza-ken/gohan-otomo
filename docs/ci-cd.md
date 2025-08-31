# CI/CD 設定書

## GitHub Actions CI設定

### 設定ファイル
- **場所**: `.github/workflows/ci.yml`
- **トリガー**: main/developブランチへのpush、PR作成時

### CI実行内容

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    - name: Start services
      run: docker compose up -d
    - name: Wait for services to be ready
      run: |
        echo "Waiting for database to be ready..."
        docker compose exec -T web bash -c 'until pg_isready -h db -p 5432; do echo "Waiting for postgres..."; sleep 2; done'
    - name: Install dependencies
      run: docker compose exec -T web bundle install
    - name: Setup database
      run: |
        docker compose exec -T web rails db:create
        docker compose exec -T web rails db:migrate
    - name: Run RSpec tests
      run: docker compose exec -T web bundle exec rspec
    - name: Run Rubocop lint check
      run: docker compose exec -T web bundle exec rubocop
    - name: Run Brakeman security check
      run: docker compose exec -T web bundle exec brakeman --quiet --format json
    - name: Stop services
      if: always()
      run: docker compose down
```

## Docker設定

### 開発環境
- **ファイル**: `compose.yml`
- **サービス**: `web` (Rails), `db` (PostgreSQL)

### Dockerコマンド

```bash
# コンテナ起動
docker compose up

# コンテナ停止
docker compose down

# 再ビルド（gem追加時等）
docker compose build --no-cache

# コンテナ内でコマンド実行
docker compose exec web [コマンド]
```

### 設定詳細

```yaml
services:
  db:
    image: postgres
    restart: always
    environment:
      TZ: Asia/Tokyo
      POSTGRES_PASSWORD: password
    volumes:
      - postgresql_data:/var/lib/postgresql
    ports:
      - 5432:5432
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d myapp_development -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bash -c "bundle install && bundle exec rails db:prepare && rm -f tmp/pids/server.pid && ./bin/dev"
    tty: true
    stdin_open: true
    volumes:
      - .:/myapp
      - bundle_data:/usr/local/bundle:cached
      - node_modules:/myapp/node_modules
    environment:
      TZ: Asia/Tokyo
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy
```

## テスト実行フロー

### 1. 自動テスト項目
- **RSpec**: 全モデル・コントローラー・フィーチャーテスト
- **Rubocop**: コードスタイルチェック
- **Brakeman**: セキュリティ脆弱性チェック

### 2. テスト実行環境
- **OS**: Ubuntu Latest
- **Ruby**: 3.3.6 (Docker内)
- **Rails**: 7.2
- **PostgreSQL**: 17.6

### 3. CI実行時間
- **平均実行時間**: 約3-5分（予想）
- **DB準備**: 約30秒
- **テスト実行**: 約1-2分
- **Lint**: 約30秒

## セキュリティチェック

### Brakeman設定
- **実行**: CI時に自動実行
- **出力**: JSON形式
- **チェック項目**: 
  - SQL injection
  - XSS vulnerabilities
  - CSRF issues
  - Command injection
  - File access vulnerabilities

### Rubocop設定
- **設定ファイル**: `.rubocop.yml`
- **ベース**: `rubocop-rails-omakase`
- **プラグイン**: Rails、RSpec、Performance、Haml

## デプロイメント（今後実装予定）

### Render設定
- **プラットフォーム**: Render
- **デプロイトリガー**: mainブランチpush時
- **環境変数**: 本番用設定

### デプロイフロー（計画）
```
1. mainブランチにマージ
2. GitHub Actions CI実行
3. テスト・Lintパス
4. Render自動デプロイ実行
5. 本番環境更新
```

## 環境変数管理

### 開発環境
```bash
# Docker Compose内で設定
POSTGRES_PASSWORD=password
TZ=Asia/Tokyo
RAILS_ENV=development
```

### 本番環境（予定）
```bash
RAILS_ENV=production
SECRET_KEY_BASE=[本番用シークレット]
DATABASE_URL=[本番DB URL]
REDIS_URL=[Redis URL]
S3_BUCKET=[画像ストレージ]
```

## ローカル開発コマンド

### 基本コマンド
```bash
# 開発サーバー起動
docker compose up

# テスト実行
docker compose exec web bundle exec rspec

# コードチェック
docker compose exec web bundle exec rubocop

# セキュリティチェック
docker compose exec web bundle exec brakeman

# DB操作
docker compose exec web rails db:create
docker compose exec web rails db:migrate
docker compose exec web rails db:seed
```

### トラブルシューティング
```bash
# コンテナログ確認
docker compose logs web
docker compose logs db

# コンテナ再構築
docker compose down
docker compose build --no-cache
docker compose up

# DB リセット
docker compose exec web rails db:drop db:create db:migrate
```

## パフォーマンス監視（今後実装予定）

### 監視項目
- レスポンス時間
- DB クエリ実行時間
- メモリ使用量
- エラー率

### 監視ツール
- New Relic（候補）
- Sentry（エラー監視）
- 独自ダッシュボード
