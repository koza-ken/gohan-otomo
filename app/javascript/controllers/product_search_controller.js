import { Controller } from "@hotwired/stimulus"

// 楽天商品検索機能を提供するStimulusコントローラー
// 商品名からAPI経由で商品候補を取得し、ユーザーが選択した画像URLを自動設定
export default class extends Controller {
  static targets = [
    "titlePreview",    // ボタン内の商品名表示
    "status",          // ローディング・エラー・成功メッセージ表示
    "candidates",      // 候補表示エリア全体
    "candidatesList"   // 候補グリッド
  ]

  // コントローラー初期化時に実行
  connect() {
    console.log("🛒 商品検索コントローラー初期化")
    
    // 商品名フィールドの変更を監視してプレビューを更新
    this.updateTitlePreview()
    this.setupTitleFieldListener()
  }
  
  // 商品名フィールドの変更を監視
  setupTitleFieldListener() {
    const titleField = this.getTitleField()
    if (titleField) {
      titleField.addEventListener('input', () => {
        this.updateTitlePreview()
      })
    }
  }
  
  // ボタン内の商品名プレビューを更新
  updateTitlePreview() {
    const titleField = this.getTitleField()
    const title = titleField?.value?.trim()
    
    if (this.hasTitlePreviewTarget) {
      this.titlePreviewTarget.textContent = title || '商品名'
    }
  }
  
  // 商品検索を実行
  async searchProducts() {
    const titleField = this.getTitleField()
    const title = titleField?.value?.trim()
    
    // バリデーション
    if (!title) {
      this.showError('商品名を入力してください')
      return
    }
    
    if (title.length > 100) {
      this.showError('商品名は100文字以内で入力してください')
      return
    }
    
    this.showLoading()
    
    try {
      console.log(`🔍 商品検索開始: ${title}`)
      
      // APIエンドポイントに商品検索リクエスト
      const response = await fetch('/api/rakuten/search_products', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ title: title })
      })
      
      const result = await response.json()
      
      if (response.ok && result.success) {
        if (result.products && result.products.length > 0) {
          console.log(`✅ 商品検索成功: ${result.count}件取得`)
          this.displayCandidates(result.products)
        } else {
          this.showMessage(result.message || `「${title}」に該当する商品が見つかりませんでした`, 'info')
        }
      } else {
        this.showError(result.error || '商品検索に失敗しました')
      }
      
    } catch (error) {
      console.error('🚨 商品検索エラー:', error)
      this.showError('ネットワークエラーが発生しました。時間をおいて再試行してください。')
    }
  }
  
  // 商品候補を表示
  displayCandidates(products) {
    console.log(`🛒 楽天API検索成功: ${products.length}件の商品を表示`)
    
    const candidatesHtml = products.map((product, index) => `
      <div class="border rounded-lg p-3 cursor-pointer hover:bg-orange-100 transition-colors"
           data-action="click->product-search#selectProduct"
           data-product-search-image-url="${product.image_url || ''}"
           data-product-search-product-title="${this.escapeHtml(product.title)}"
           data-product-search-price="${product.price}">
        ${product.image_url ? 
          `<div class="relative w-full h-24 bg-gray-100 rounded mb-2 flex items-center justify-center">
             <img src="/api/rakuten/proxy_image?url=${encodeURIComponent(product.image_url)}" 
                  alt="${this.escapeHtml(product.title)}" 
                  class="w-full h-24 object-cover rounded absolute inset-0"
                  loading="lazy"
                  style="display: block;"
                  onload="this.nextElementSibling.style.display='none';"
                  onerror="console.warn('楽天画像読み込み失敗:', this.src); this.style.display='none'; this.nextElementSibling.style.display='flex';">
             <div class="absolute inset-0 bg-gray-100 rounded flex items-center justify-center text-gray-500 text-xs" style="display: none;">
               <div class="text-center">
                 <div class="mb-1">🚫</div>
                 <div>プロキシエラー</div>
               </div>
             </div>
           </div>` :
          `<div class="bg-gray-100 h-24 flex items-center justify-center rounded mb-2 text-gray-500 text-xs">
             <div class="text-center">
               <div class="mb-1">📷</div>
               <div>画像なし</div>
             </div>
           </div>`
        }
        <p class="text-xs text-gray-600 truncate mb-1" title="${this.escapeHtml(product.title)}">
          ${this.truncateText(product.title, 30)}
        </p>
        <p class="text-xs text-orange-600 font-medium">¥${product.price.toLocaleString()}</p>
        <p class="text-xs text-gray-500">${this.escapeHtml(product.shop_name)}</p>
      </div>
    `).join('')
    
    this.candidatesListTarget.innerHTML = candidatesHtml
    this.candidatesTarget.classList.remove('hidden')
    this.hideStatus()
    
    this.showMessage(`${products.length}件の商品候補が見つかりました`, 'success')
  }
  
  // 商品を選択（画像URLを自動設定）
  selectProduct(event) {
    const card = event.currentTarget
    const imageUrl = card.dataset.productSearchImageUrl
    const productTitle = card.dataset.productSearchProductTitle
    const price = card.dataset.productSearchPrice
    
    if (!imageUrl) {
      this.showError('この商品には画像がありません')
      return
    }
    
    // 画像URLフィールドに自動設定
    const imageUrlField = this.getImageUrlField()
    if (imageUrlField) {
      imageUrlField.value = imageUrl
      
      // 画像URLフィールドのchangeイベントを発火（既存のプレビュー機能を動作させる）
      imageUrlField.dispatchEvent(new Event('input', { bubbles: true }))
    }
    
    // 選択状態を視覚的に表示
    this.showSelectedState(card, productTitle, price)
    
    console.log(`🎯 商品選択: ${productTitle}`)
  }
  
  // 選択状態の表示
  showSelectedState(selectedCard, productTitle, price) {
    // 全てのカードの選択状態をリセット
    this.candidatesListTarget.querySelectorAll('.border-green-500').forEach(card => {
      card.classList.remove('border-green-500', 'bg-green-50')
    })
    
    // 選択されたカードをハイライト
    selectedCard.classList.add('border-green-500', 'bg-green-50')
    
    // 選択成功メッセージ
    this.showMessage(`「${this.truncateText(productTitle, 25)}」の画像を設定しました`, 'success')
  }
  
  // 検索結果をクリア
  clearResults() {
    if (this.hasCandidatesTarget) {
      this.candidatesTarget.classList.add('hidden')
    }
    this.hideStatus()
    console.log('🗑️ 検索結果をクリア')
  }
  
  // ローディング表示
  showLoading() {
    this.showStatus(`
      <div class="flex items-center space-x-2 text-orange-600">
        <div class="animate-spin inline-block w-4 h-4 border-2 border-orange-500 border-t-transparent rounded-full"></div>
        <span>商品を検索中...</span>
      </div>
    `)
  }
  
  // エラーメッセージ表示
  showError(message) {
    this.showStatus(`
      <div class="bg-red-50 border border-red-200 rounded-lg p-3">
        <p class="text-red-600 text-sm">⚠️ ${message}</p>
      </div>
    `)
  }
  
  // 情報メッセージ表示
  showMessage(message, type = 'info') {
    const colors = {
      success: 'bg-green-50 border-green-200 text-green-600',
      info: 'bg-blue-50 border-blue-200 text-blue-600',
      warning: 'bg-yellow-50 border-yellow-200 text-yellow-600'
    }
    
    const colorClass = colors[type] || colors.info
    
    this.showStatus(`
      <div class="${colorClass} border rounded-lg p-3">
        <p class="text-sm">✅ ${message}</p>
      </div>
    `)
    
    // 3秒後に自動的にメッセージを隠す
    setTimeout(() => {
      this.hideStatus()
    }, 3000)
  }
  
  // ステータス表示（共通）
  showStatus(html) {
    if (this.hasStatusTarget) {
      this.statusTarget.innerHTML = html
      this.statusTarget.classList.remove('hidden')
    }
  }
  
  // ステータス非表示
  hideStatus() {
    if (this.hasStatusTarget) {
      this.statusTarget.classList.add('hidden')
    }
  }
  
  // 商品名フィールドを取得
  getTitleField() {
    return this.element.closest('form')?.querySelector('input[name*="title"]')
  }
  
  // 画像URLフィールドを取得
  getImageUrlField() {
    return this.element.closest('form')?.querySelector('input[name*="image_url"]')
  }
  
  // CSRFトークンを取得
  getCSRFToken() {
    return document.querySelector('[name="csrf-token"]')?.content || ''
  }
  
  // HTMLエスケープ
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
  
  // テキスト省略
  truncateText(text, length) {
    return text.length > length ? text.substring(0, length) + '...' : text
  }
}