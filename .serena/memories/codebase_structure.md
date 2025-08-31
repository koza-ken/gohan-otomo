# コードベース構造

## プロジェクト全体構造
```
gohan-otomo/
├── app/                    # Railsアプリケーション本体
│   ├── controllers/        # コントローラー
│   ├── models/            # モデル（ビジネスロジック）
│   ├── views/             # ビュー（Hamlテンプレート）
│   ├── javascript/        # Stimulusコントローラー
│   ├── assets/           # CSS、画像ファイル
│   ├── helpers/          # ビューヘルパー
│   ├── mailers/          # メーラー
│   ├── jobs/             # バックグラウンドジョブ
│   └── channels/         # Action Cable
├── spec/                  # RSpecテスト
├── config/               # Rails設定
├── db/                   # データベース関連
├── docs/                 # プロジェクトドキュメント
├── .github/workflows/    # GitHub Actions CI
└── compose.yml          # Docker Compose設定
```

## 現在の実装状況
- **Models**: 基本構造のみ（ApplicationRecord）
- **Controllers**: 基本構造のみ（ApplicationController）
- **Views**: Railsデフォルトレイアウト
- **テスト**: RSpec環境設定済み
- **Docker**: 完全設定済み

## 予定される主要モデル
```ruby
# STI（Single Table Inheritance）設計
class Post < ApplicationRecord
  # 基底クラス
end

class RecommendPost < Post
  # おすすめ投稿
end

class ReportPost < Post
  # 食べてみた投稿
end

class User < ApplicationRecord
  # ユーザー（Devise使用予定）
end

class Like < ApplicationRecord
  # いいね機能
end
```

## ディレクトリ使用方針

### app/controllers/
- RESTfulな設計
- 認証が必要なコントローラーはbefore_action

### app/models/
- ビジネスロジック中心
- バリデーション、アソシエーション
- 必要に応じてconcerns/で共通ロジック分離

### app/views/
- **Hamlテンプレート**（ERBではない）
- パーシャルを活用
- レスポンシブデザイン

### spec/
- models/, controllers/, features/でテスト分類
- support/にテスト共通設定
- factories/にFactoryBot定義

### docs/
- architecture.md: 技術設計
- ci-cd.md: CI/CD設定
- overview.md: 詳細仕様
- todo.md: 開発メモ

## 開発の進め方
1. 機能単位でブランチ作成
2. TDD（テストファースト）で開発
3. Docker環境で動作確認
4. CI通過後にマージ