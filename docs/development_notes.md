# 開発ノート

## 重要な設計判断

### STI廃止とPost-Comment関連設計への変更 (05_post_model_#7)

**変更理由**:
- RecommendPostとReportPostのSTI設計から、Post（おすすめ投稿）とComment（感想コメント）の関連設計に変更
- おすすめ投稿と感想は本質的に異なる機能であることが判明
- シンプルで理解しやすい設計を優先

**実装順序の変更 (06_post_crud_#9)**:
- 当初: post-models → image-upload → post-crud
- 変更: post-models → post-crud → image-upload
- **理由**: 投稿フォームがないのに画像機能を作るのは非効率

### counter_cache vs delegate の設計判断

**採用**: メソッド形式を維持、delegateは使用しない

```ruby
# 現在の実装
def comments_count
  comments.count
end

# 将来のcounter_cache対応時
def comments_count
  self[:comments_count]  # カラムの値を返すだけ（高速）
end
```

**理由**: 
- delegateを使うと将来のcounter_cache導入時の変更範囲が大きくなる
- メソッド形式なら実装だけ変更、インターフェースは変更不要

### dependent: :nullify の採用理由

**User → Post, Comment**:
```ruby
has_many :posts, dependent: :nullify
has_many :comments, dependent: :nullify
```

**理由**:
- 退会後もコンテンツを保持し、コミュニティ価値を維持
- 「退会済みユーザー」として表示（Safe Navigation Operator使用）

## テスト戦略

### 包括的テストカバレッジ (88テスト)
- **Model specs**: バリデーション、アソシエーション、メソッド
- **FactoryBot**: リアルなテストデータとtrait活用
- **境界値テスト**: 文字数制限、URL形式、関連チェック

### FactoryBot設計パターン
```ruby
# 基本 + trait パターン
factory :post do
  association :user
  title { "テスト商品" }
  description { "これは美味しいご飯のお供です" }
  link { nil }  # デフォルトはnull
  
  trait :with_link do
    link { "https://example.com/product" }
  end
end
```

## Rails 7ベストプラクティス

### ルーティング設計
```ruby
# RESTfulルーティング
resources :posts  # 7つの標準ルート

# ネストルーティング（プロフィール）
resources :users, only: [] do
  resource :profile, only: [:show, :edit, :update]
end
```

### バリデーション設計
- URL形式チェック: `URI::DEFAULT_PARSER.make_regexp(%w[http https])`
- 条件付きバリデーション: `if: :link?` で空の場合をスキップ
- 適切な文字数制限: title(100), description(200), content(300)

## 技術負債と改善点

### 将来的な改善予定
1. **counter_cacheの導入**: N+1問題の解決
2. **バックグラウンドジョブ**: 外部画像取得の非同期化
3. **キャッシュ戦略**: 投稿一覧の高速化
4. **画像最適化**: WebP対応、レスポンシブ画像

### セキュリティ考慮事項
- Strong Parameters徹底使用
- URL形式バリデーション（XSS対策）
- 認証・認可の適切な設定
- Brakeman定期チェック（現在：No warnings）

## 開発環境設定

### 重要な設定ファイル
- `.rubocop.yml`: Rails/Delegateを除外（counter_cache対応のため）
- `spec/support/factory_bot.rb`: テストデータ管理
- `CLAUDE.md`: プロジェクト全体設計
- `docs/branch.md`: ブランチ戦略と実装順序