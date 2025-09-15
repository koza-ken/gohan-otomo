# 🍚 お供だち - 開発者ガイド

## プロジェクト概要

ユーザーが「ごはんのお供」を投稿・共有できるWebアプリケーション。
投稿・いいね・コメント機能を提供します。

## 開発環境セットアップ

```bash
# コンテナ起動
docker compose up

# 初回セットアップ
docker compose exec web rails db:create db:migrate
docker compose exec web rails db:seed

# ブラウザでアクセス
http://localhost:3000
```

## 技術スタック

- **Ruby on Rails 7.2** - メインフレームワーク
- **PostgreSQL** - データベース
- **TailwindCSS v4** - スタイリング
- **Turbo + Stimulus** - フロントエンド
- **Active Storage + Cloudinary** - 画像管理
- **楽天市場API** - 商品検索・画像取得
- **RSpec + FactoryBot** - テスト
- **Docker** - 開発環境

## 主要機能

### 実装済み機能 ✅
- **ユーザー認証**: Devise使用、日本語対応
- **投稿CRUD**: 商品名・おすすめポイント・通販リンク・画像
- **いいね機能**: Turbo Stream によるリアルタイム更新
- **コメント機能**: Ajax対応、削除権限制御
- **楽天API連携**: 商品名・URL検索による画像自動取得
- **画像システム**: アップロード → 外部URL → プレースホルダーの3段階フォールバック
- **レスポンシブデザイン**: モバイル・デスクトップ対応
- **SNS連携**: Xシェア機能
- **初回案内モーダル**: LocalStorage使用

### アーキテクチャ設計

#### Service Object パターン
```ruby
# ビジネスロジックをサービス層に分離
class RakutenSearchService
  def call
    # 商品検索・URL解析・エラーハンドリング
  end
end
```

#### N+1問題対策
```ruby
# includes による関連データ一括取得
@posts = Post.includes(:user, :comments, :likes)
             .page(params[:page]).per(8)
```

#### ハイブリッド画像システム
```ruby
def display_image(size = :medium)
  return medium_image if image.attached?
  image_url.presence  # 外部URLフォールバック
end
```

## データベース設計

### 主要テーブル
```sql
Users: id, email, display_name, favorite_foods, disliked_foods
Posts: id, user_id, title, description, link, image_url
Comments: id, user_id, post_id, content
Likes: id, user_id, post_id (ユニーク制約)
```

## 開発コマンド

### テスト実行
```bash
docker compose exec web bundle exec rspec              # 全テスト
docker compose exec web bundle exec rspec --tag model  # モデルテスト
docker compose exec web bundle exec rspec --tag system # システムテスト
```

### コード品質
```bash
docker compose exec web bundle exec rubocop    # コード規約チェック
docker compose exec web bundle exec brakeman   # セキュリティチェック
docker compose exec web bundle exec rubocop -a # 自動修正
```

### データベース
```bash
docker compose exec web rails db:migrate       # マイグレーション
docker compose exec web rails db:seed          # テストデータ投入
docker compose exec web rails db:reset         # DB再作成
```

## セキュリティ対策

### SSRF攻撃防止
- 楽天ドメインのみ許可するURL制限
- モデルバリデーション + フロントエンド制限の多層防御

### Rails 7セキュリティ
- Turbo対応の確認ダイアログ（`data-turbo-confirm`）
- CSRF保護、SQLインジェクション対策

## パフォーマンス最適化

### 実装済み最適化
- **N+1問題解決**: SQLクエリ64%削減（11回→4回）
- **画像最適化**: WebP対応、variant処理
- **LocalStorage活用**: 初回判定でサーバー負荷軽減
- **Turbo Stream**: リアルタイム更新でページリロード削減

## テスト戦略

### テスト構成（315例・100%成功）
- **Model Spec**: 115例（バリデーション・アソシエーション）
- **Request Spec**: 143例（HTTP処理・認証）
- **System Spec**: 58例（JavaScript・ブラウザ操作）

### 重要なテストパターン
```ruby
# Active Storage テスト
trait :with_attached_image do
  after(:build) do |post|
    post.image.attach(io: StringIO.new("fake"), filename: 'test.jpg')
  end
end

# Request Spec注意点
let(:post_record) { ... }  # HTTPメソッドと同名変数は禁止
```

## トラブルシューティング

### よくある問題
1. **画像表示エラー**: Cloudinary設定確認（`config/storage.yml`）
2. **CORS問題**: プロキシエンドポイント使用
3. **テスト失敗**: FactoryBot設定確認

### デバッグコマンド
```bash
docker compose logs web           # アプリログ確認
docker compose exec web rails c   # Railsコンソール
docker logs -f container_name     # リアルタイムログ
```

## 外部サービス設定

### 必要な環境変数
```bash
# 楽天API
RAKUTEN_APPLICATION_ID=your_app_id

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## 本番環境

### デプロイ先
- **Render**: https://gohan-otomo.onrender.com
- **データベース**: PostgreSQL
- **画像ストレージ**: Cloudinary

### 本番設定のポイント
- 環境変数の適切な設定
- アセットプリコンパイル
- データベースマイグレーション

---

## 参考資料

- **開発ドキュメント目次**: `docs/INDEX.md`
- **技術概要・学習ポイント**: `docs/development/technical_overview.md`
- **ブランチ別実装記録**: `docs/development/branches_summary.md`
- **機能別実装詳細**: `docs/features/` （いいね・楽天API・SNS連携等）

詳細な実装パターンや学習ポイントは上記docsを参照してください。
