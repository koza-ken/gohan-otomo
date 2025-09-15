# 📚 開発ドキュメント目次

## 📁 **フォルダ構成**

```
docs/
├── features/           # 機能別技術ドキュメント
├── development/        # 開発・技術関連
├── project/           # プロジェクト管理
├── technologies/      # 技術要素別復習ガイド
└── INDEX.md          # このファイル
```

---

## 🚀 **機能別ドキュメント** (`features/`)

### 主要機能の実装詳細 - 復習・学習用
- **[いいね機能](./features/likes.md)** - Turbo Stream、Ajax、Rails 7パターン
- **[SNS連携](./features/sns_integration.md)** - X（旧Twitter）投稿ボタン実装
- **[楽天API連携](./features/rakuten_api.md)** - 外部API統合、CORS対策、プロキシパターン
- **[画像最適化](./features/image_optimization.md)** - WebP対応、パフォーマンス向上
- **[レスポンシブデザイン](./features/responsive_design.md)** - モバイルUX、段階的改善

---

## 🛠️ **開発・技術ドキュメント** (`development/`)

### 技術解説・実装ガイド
- **[技術概要](./development/technical_overview.md)** - 主要技術の実装解説・学習ポイント
- **[ブランチ別実装記録](./development/branches_summary.md)** - 開発履歴・学習テーマ別まとめ
- **[テストガイド](./development/testing_guide.md)** - CI・テスト修正の記録
- **[最新実装状況](./development/latest_implementation.md)** - 20_yattaka最新実装詳細

---

## 📚 **技術要素別復習ガイド** (`technologies/`)

### 技術要素ごとの詳細解説 - 復習・学習用
- **[Stimulus Controllers](./technologies/stimulus_controllers.md)** - Rails 7標準フロントエンド制御
- **[楽天API連携](./technologies/rakuten_api.md)** - 外部API統合・CORS対策・プロキシパターン
- **[Service Object](./technologies/service_objects.md)** - ビジネスロジック分離・責任分離設計
- **[Active Storage](./technologies/active_storage.md)** - ファイルアップロード・画像処理・エラーハンドリング
- **[Turbo Stream](./technologies/turbo_stream.md)** - リアルタイム部分更新・Ajax代替

---

## 📋 **プロジェクト管理** (`project/`)

### 開発管理・計画
- **[ブランチ履歴](./project/branch_history.md)** - 全ブランチの詳細開発履歴
- **[リリースチェックリスト](./project/release_checklist.md)** - デプロイ前確認項目
- **[将来のロードマップ](./project/future_roadmap.md)** - 次期開発の推奨事項

---

## 🎯 **目的別ガイド**

### 👋 **新しく参加する開発者**
1. [`development/technical_overview.md`](./development/technical_overview.md) - 技術概要の把握
2. [`development/branches_summary.md`](./development/branches_summary.md) - 開発経緯の理解
3. `/CLAUDE.md`（ルートディレクトリ） - 開発環境構築

### 🔍 **特定機能を学習したい場合**
- `features/` フォルダの該当機能ドキュメントを参照
- 各ファイルには実装パターン・学習ポイント・コード例を記載

### ⚡ **特定技術を復習したい場合**
- `technologies/` フォルダの該当技術ドキュメントを参照
- 技術概要・必要性・実装内容・学習ポイント・応用方法を完全網羅

### 📈 **開発の進捗・判断を振り返りたい場合**
- [`development/branches_summary.md`](./development/branches_summary.md) - 学習テーマ別まとめ
- [`project/branch_history.md`](./project/branch_history.md) - 詳細な開発履歴

### 🚀 **次の開発を進めたい場合**
- [`development/latest_implementation.md`](./development/latest_implementation.md) - 最新状況
- [`project/future_roadmap.md`](./project/future_roadmap.md) - 推奨開発方針

---

## 🎓 **学習価値の高いドキュメント**

### **Rails 7ベストプラクティス**
- [`features/likes.md`](./features/likes.md) - Turbo Stream実装
- [`features/rakuten_api.md`](./features/rakuten_api.md) - Service Object パターン
- [`development/technical_overview.md`](./development/technical_overview.md) - N+1問題解決

### **パフォーマンス最適化**
- [`features/image_optimization.md`](./features/image_optimization.md) - WebP対応
- [`development/technical_overview.md`](./development/technical_overview.md) - SQLクエリ最適化

### **UX設計**
- [`features/responsive_design.md`](./features/responsive_design.md) - モバイルファースト
- [`development/branches_summary.md`](./development/branches_summary.md) - 段階的改善アプローチ

### **セキュリティ対策**
- [`features/rakuten_api.md`](./features/rakuten_api.md) - SSRF攻撃防止
- [`development/technical_overview.md`](./development/technical_overview.md) - Rails 7セキュリティ

---

このドキュメント群は、プロジェクトの技術的成長と学習の記録として、将来の開発に活用できます。