# ⚡ Stimulus Controllers - 完全復習ガイド

## 概要

**Stimulus** はRails 7標準のJavaScriptフレームワーク。HTMLファーストの設計思想で、既存のHTMLに「少しのJavaScript」を追加してインタラクティブな機能を実現します。

### 基本的な特徴
- **HTML中心設計**: HTMLにdata属性を追加するだけで動作
- **軽量**: 複雑なSPAフレームワークと違い、必要な部分だけJS追加
- **Rails統合**: Turboと組み合わせて、Rails標準のフロントエンド構成

## このアプリでの役割

お供だちアプリでは、以下の8つのStimulusコントローラーを実装し、リッチなユーザー体験を実現：

### 📋 **実装済みコントローラー一覧**

1. **ProductSearchController** - 楽天API商品検索
2. **UnifiedPreviewController** - 統合画像プレビュー
3. **WelcomeModalController** - 初回案内モーダル
4. **DropdownController** - ドロップダウンメニュー
5. **FlashController** - フラッシュメッセージ制御
6. **PasswordToggleController** - パスワード表示切り替え
7. **FloatingMenuController** - フローティングメニュー
8. **ImagePreviewController** - 画像プレビュー（旧版）

## 実装内容

### 🛒 **1. ProductSearchController**
**役割**: 楽天API連携による商品検索・画像選択機能

```javascript
// app/javascript/controllers/product_search_controller.js
export default class extends Controller {
  static targets = ["title", "candidatesDesktop", "candidatesMobile"]

  async searchByProductName() {
    const title = this.titleTarget.value.trim()
    if (!title) return

    try {
      const response = await fetch('/api/rakuten/search_products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title })
      })

      const data = await response.json()
      this.displayCandidates(data.products)
    } catch (error) {
      console.error('楽天API検索エラー:', error)
    }
  }
}
```

**使用箇所**: `app/views/posts/_form.html.erb`
```erb
<div data-controller="product-search">
  <input data-product-search-target="title">
  <button data-action="click->product-search#searchByProductName">検索</button>
</div>
```

### 🖼️ **2. UnifiedPreviewController**
**役割**: ファイルアップロード・URL入力両方の画像プレビューを統一制御

```javascript
export default class extends Controller {
  static targets = [
    "imageSourceRadio", "urlSection", "fileSection",
    "fileInput", "urlInput", "activePreviewArea"
  ]

  switchImageSource() {
    const selectedValue = this.getSelectedImageSource()

    if (selectedValue === 'url') {
      this.showUrlSection()
      this.hideFileSection()
    } else if (selectedValue === 'file') {
      this.showFileSection()
      this.hideUrlSection()
    }
  }

  updateFilePreview() {
    const file = this.fileInputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.showPreview(e.target.result, `ファイル: ${file.name}`)
      }
      reader.readAsDataURL(file)
    }
  }
}
```

### 🎉 **3. WelcomeModalController**
**役割**: 初回アクセス時のアプリ説明モーダル表示（LocalStorage連携）

```javascript
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    const hasVisited = localStorage.getItem('has_visited_otomo')
    const isTopPage = ['/', '/posts'].includes(window.location.pathname)

    if (!hasVisited && isTopPage) {
      setTimeout(() => this.showModal(), 500)
    }
  }

  closeModal() {
    localStorage.setItem('has_visited_otomo', 'true')
    this.hideModal()
  }
}
```

### 🔽 **4. DropdownController**
**役割**: 投稿詳細での編集・削除メニュー制御

```javascript
export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.showMenu()
    } else {
      this.hideMenu()
    }
  }

  // 外部クリックで閉じる
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideMenu()
    }
  }
}
```

### 💬 **5. FlashController**
**役割**: フラッシュメッセージの自動消去制御

```javascript
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.style.opacity = '0'
      setTimeout(() => this.element.remove(), 300)
    }, 5000)
  }
}
```

### 🔒 **6. PasswordToggleController**
**役割**: パスワードフィールドの表示・非表示切り替え

```javascript
export default class extends Controller {
  static targets = ["field", "icon"]

  toggle() {
    const isPassword = this.fieldTarget.type === "password"

    this.fieldTarget.type = isPassword ? "text" : "password"
    this.iconTarget.src = isPassword ? "/icons/eye_hide.svg" : "/icons/eye_show.svg"
  }
}
```

## 学習ポイント

### 🎯 **1. HTMLファースト設計**
```erb
<!-- HTMLにdata属性を追加するだけで機能追加 -->
<div data-controller="product-search">
  <input data-product-search-target="title">
  <button data-action="click->product-search#searchProducts">検索</button>
</div>
```
- JavaScriptコードとHTMLが分離されている
- デザイナーでもdata属性の追加は簡単
- 段階的な機能拡張が可能

### 🔧 **2. targets/actions/valuesの活用**
```javascript
static targets = ["title", "candidates"]    // DOM要素の参照
static actions = ["click", "input"]          // イベントハンドリング
static values = { url: String }             // 設定値の管理
```

### 🚀 **3. Rails 7との統合パターン**
- **Turbo Streamとの連携**: フォーム送信後の部分更新
- **CSRF トークン**: Rails標準のセキュリティ機能
- **国際化**: Rails I18nとの連携

### ⚠️ **4. 実装時の注意点**

#### **コントローラー登録必須**
```javascript
// app/javascript/controllers/index.js に必ず追加
import ProductSearchController from "./product_search_controller"
application.register("product-search", ProductSearchController)
```

#### **命名規約の遵守**
- ファイル名: `snake_case_controller.js`
- HTML: `data-controller="kebab-case"`
- クラス名: `PascalCaseController`

## 関連ファイル

### 📁 **コントローラーファイル**
```
app/javascript/controllers/
├── product_search_controller.js    # 楽天API検索
├── unified_preview_controller.js   # 画像プレビュー統合
├── welcome_modal_controller.js     # 初回案内モーダル
├── dropdown_controller.js          # ドロップダウンメニュー
├── flash_controller.js             # フラッシュメッセージ
├── password_toggle_controller.js   # パスワード表示切り替え
└── index.js                        # コントローラー登録
```

### 🧪 **テストファイル**
```
spec/system/
├── posts_spec.rb              # 投稿機能統合テスト
├── likes_spec.rb              # いいね機能統合テスト
└── comments_spec.rb           # コメント機能統合テスト
```

### 🎨 **ビューファイル**
```
app/views/
├── posts/_form.html.erb       # 投稿フォーム（商品検索）
├── shared/_welcome_modal.html.erb  # ウェルカムモーダル
└── layouts/application.html.erb    # フラッシュメッセージ
```

## 他プロジェクトでの応用

### 🔄 **汎用的なパターン**

#### **1. API連携パターン**
```javascript
async callAPI(endpoint, data) {
  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
    return await response.json()
  } catch (error) {
    console.error('API呼び出しエラー:', error)
  }
}
```

#### **2. プレビュー機能パターン**
```javascript
updatePreview(file) {
  const reader = new FileReader()
  reader.onload = (e) => {
    this.previewTarget.src = e.target.result
    this.showPreviewArea()
  }
  reader.readAsDataURL(file)
}
```

#### **3. LocalStorage活用パターン**
```javascript
connect() {
  const hasVisited = localStorage.getItem('visited_flag')
  if (!hasVisited) {
    this.showFirstTimeUI()
  }
}

markAsVisited() {
  localStorage.setItem('visited_flag', 'true')
}
```

### 🎁 **再利用可能コンポーネント**
- **ドロップダウンメニュー**: 任意の要素で使える汎用メニュー
- **パスワード切り替え**: 全認証フォームで活用
- **フラッシュメッセージ**: アプリケーション共通機能
- **モーダル制御**: 各種ダイアログで応用可能

---

**Stimulus Controllersは、お供だちアプリのユーザー体験を大きく向上させ、
Rails 7の標準的なフロントエンド開発手法として重要な技術基盤となっています。**