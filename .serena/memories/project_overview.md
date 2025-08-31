# ご飯のお供投稿アプリ（gohan-otomo）プロジェクト概要

## プロジェクト目的
ユーザーが「ご飯のお供」や「おかず」を投稿・共有できるWebアプリケーション。
投稿にはおすすめポイントや通販リンク、画像などを添えることができ、他のユーザーは一覧から投稿を閲覧し、いいねを付けることができる。

## 主な機能
- ユーザー登録・認証（Devise使用予定）
- 2つの投稿タイプ：
  - おすすめ投稿（RecommendPost）：商品紹介
  - 食べてみた投稿（ReportPost）：実食レビュー
- ハイブリッド画像方式（ユーザーアップロード + 外部API取得）
- プロフィール公開機能
- いいね機能
- SNS連携（X/Twitter）

## 技術スタック
- **バックエンド**: Ruby 3.3.6, Rails 7.2.2
- **データベース**: PostgreSQL
- **フロントエンド**: TailwindCSS v4 + Hotwire (Turbo/Stimulus)
- **テンプレート**: Haml (Hamlit)
- **開発環境**: Docker + Docker Compose
- **テスト**: RSpec + FactoryBot + Faker
- **CI/CD**: GitHub Actions

## 設計方針
- モバイルファースト設計
- STI（Single Table Inheritance）でPost継承
- Dockerベースの開発環境
- コンテナ内とローカルRuby環境の併用