# コードスタイル・規約

## Ruby/Railsスタイル
- **Linter**: Rubocop（rails-omakaseベース）
- **プラグイン**: rails, rspec, performance, haml
- **設定**: `.rubocop.yml`で定義済み

### 主な設定
- AbcSize: Max 30
- ClassLength: Max 300（コメント除外）
- CyclomaticComplexity: Max 30
- LineLength: 無効（制限なし）
- 日本語コメント許可（AsciiComments: false）
- ドキュメント必須なし（Documentation: false）

## テンプレートエンジン
- **ERBではなくHamlを使用**
- Hamlit使用（高速なHaml実装）
- html2haml gemでERB→Haml変換可能

## テストコード
- **RSpec** + **FactoryBot** + **Faker**
- テストファイル配置: `spec/`
- FactoryBot設定: `spec/support/factory_bot.rb`

### テスト規約
- 新機能追加時は必ずテスト作成
- 正常系・異常系の両方をテスト
- FactoryBotでテストデータ作成
- `include FactoryBot::Syntax::Methods`設定済み

## フロントエンド
- **TailwindCSS v4**（従来のv3と異なる）
- **Hotwire（Turbo + Stimulus）**
- モバイルファースト設計

## 命名規約
- Rails標準に従う
- モデル: CamelCase（User, Post）
- コントローラー: CamelCase + Controller（UsersController）
- ファイル名: snake_case
- ルート: RESTful設計

## コミットメッセージ
GitHub Actionsで自動生成される場合は以下を付加：
```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```