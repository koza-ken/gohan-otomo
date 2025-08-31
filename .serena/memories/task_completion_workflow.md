# タスク完了時の実行手順

## コード変更後の必須チェック

### 1. Lintチェック
```bash
# Rubocopでコードスタイルチェック
docker compose exec web bundle exec rubocop

# 自動修正可能な問題を修正
docker compose exec web bundle exec rubocop -a
```

### 2. セキュリティチェック
```bash
# Brakemanでセキュリティ脆弱性チェック
docker compose exec web bundle exec brakeman
```

### 3. テスト実行
```bash
# 全テスト実行
docker compose exec web bundle exec rspec

# 特定のテストファイル実行（必要に応じて）
docker compose exec web bundle exec rspec spec/models/
```

### 4. 機能テスト
```bash
# 開発サーバー起動して動作確認
docker compose up
# ブラウザで http://localhost:3000 にアクセス
```

## 新機能追加時の追加手順

### モデル追加時
1. マイグレーション実行
   ```bash
   docker compose exec web rails db:migrate
   ```
2. RSpecテスト作成
   ```bash
   # spec/models/model_name_spec.rb
   # spec/factories/model_name.rb
   ```

### コントローラー追加時
1. ルート設定確認
   ```bash
   docker compose exec web rails routes
   ```
2. RSpecテスト作成（コントローラー・フィーチャー）

### Gem追加時
1. bundle install実行
   ```bash
   docker compose exec web bundle install
   ```
2. 必要に応じてコンテナ再ビルド
   ```bash
   docker compose build --no-cache
   ```

## CI/CD関連
- GitHub ActionsでPR時に自動実行：
  - RSpec
  - Rubocop
  - Brakeman
- mainブランチにマージ後も同様のチェックが実行

## コード品質維持のルール
1. **テストなしのコード変更は原則禁止**
2. **Rubocopエラーは必ず修正**
3. **Brakemanの警告は調査・対応**
4. **新機能はテストファースト**

## エラー発生時の対処
1. ログ確認
   ```bash
   docker compose logs web
   docker compose logs db
   ```
2. コンテナ再起動
   ```bash
   docker compose down
   docker compose up
   ```
3. DB問題の場合はリセット検討
   ```bash
   docker compose exec web rails db:drop db:create db:migrate
   ```