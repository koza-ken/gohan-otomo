<!--
コーディング規約（Rubocop のルールや補足）
テストの方針（RSpec, FactoryBot, システムテスト）
コミットメッセージルール (Conventional Commits など)
 -->

<!-- 環境構築に必要なファイル -->

- README.md

<!-- CLAUDE関係 -->
- CLAUDE.md // claude codeのルール
- settings.local.json // claudeが実行できるコマンド

<!-- Docker関係 -->
- Dockerfile
- compose.yml
- .dockerignore // ビルドに不要なファイルを除外

<!-- GitHub関係 -->
- .gitignore // 追跡しないファイルを除外

<!-- コミットメッセージ -->
- add: 新しい機能・ファイル追加
- fix: バグの修正
- update: バグではない機能修正
- remove: 削除
- style: 空白、フォーマット、セミコロン追加など
- refactor: 仕様に影響がないコード改善(リファクタ)
- test: テスト関連
- chore: ビルド、補助ツール、ライブラリ関連

ex:
  "add: 〇〇なため、△△を追加"



# GitHub Issue と Branch 運用ルール

## 1. Issue 管理
### 目的
開発タスクを明確化し、進捗を可視化するために利用する。

### 粒度
- 1つの Issue = 1つのタスク
- 「機能追加」「修正」「調査」など、なるべく完了条件を明確にする

### テンプレート例
```markdown
## 概要
- やりたいこと / 修正したいこと

## 完了条件
- [ ] 条件1
- [ ] 条件2

## 備考
- 補足情報や関連リンク

ラベル例
- feature → 新機能
- bug → 不具合修正
- docs → ドキュメント整備
- refactor → リファクタリング
- security → セキュリティ関連
- discussion → 調査・検討系

## 2. Branch 運用
### 基本ルール
- ブランチ名は Issue に紐付けて管理
- feature/, fix/, chore/ のプレフィックスを付ける

### 命名規則
- feature/#番号-短い説明
- fix/#番号-短い説明
- chore/#番号-短い説明

### 例
- feature/#12-add-login
- fix/#34-buggy-validation
- chore/#56-update-readme

## 3. Issue ⇔ Branch の流れ
### Issue 作成
- タスクを明確化
- 完了条件を書く
- ラベルをつける
### Branch 作成
- Issue 番号を含めたブランチ名を作成
- git checkout -b feature/#12-add-login

### 実装 & コミット
- コミットメッセージに close #12 を入れると PR マージ時に Issue が自動で閉じる
- 例: git commit -m "Add login function (close #12)"

### Pull Request 作成
- タイトルに Issue 番号を書くとわかりやすい
- PR 説明に close #12 を書く

### レビュー & マージ
- main に直接 push せず PR 経由でマージ

### Issue 自動クローズ
- PR マージと同時に関連 Issue が閉じる

## 4. コミットメッセージ例
- Add login feature (close #12)
- Fix validation error (close #34)
- Update README (close #56)

## 5. 運用まとめ
- Issue → Branch → PR → Merge の流れを徹底する
- 番号で一意に紐付けることで追跡性を確保
- コミットメッセージ or PR 説明に close #番号 を必ず入れる
- main ブランチは常にリリース可能状態を維持する
