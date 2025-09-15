import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview", "urlInput", "urlPreview", "urlStatus"]
  
  connect() {
    // Controller initialization
  }
  
  preview(event) {
    const file = event.target.files[0]
    
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove('hidden')
      }
      
      reader.readAsDataURL(file)
    } else {
      // 画像ファイルでない場合はプレビューを隠す
      this.previewTarget.classList.add('hidden')
    }
  }

  // 画像読み込みエラー時のハンドリング
  handleImageError(event) {
    const img = event.target
    const size = img.dataset.size || 'medium'
    
    // プレースホルダーに置き換える
    const placeholder = this.createPlaceholder(size)
    img.parentElement.innerHTML = placeholder
  }

  // プレースホルダーHTMLを生成
  createPlaceholder(size) {
    const heightClass = size === 'thumbnail' ? 'h-48' : 'h-64 md:h-80'
    
    return `<div class="flex items-center justify-center ${heightClass} bg-orange-100">
              <img src="/no_image.png" alt="画像がありません" class="w-full h-full object-contain">
            </div>`
  }

  // 画像URL入力時のリアルタイム検証
  validateImageUrl(event) {
    const url = event.target.value.trim()
    
    if (!url) {
      this.clearUrlPreview()
      return
    }

    // URLの基本形式をチェック
    if (!this.isValidUrl(url)) {
      this.showUrlStatus('❌ 正しいURL形式で入力してください', 'error')
      return
    }

    // 画像の実際の読み込みテスト
    this.testImageUrl(url)
  }

  // 画像URLの実際の読み込みテスト
  testImageUrl(url) {
    this.showUrlStatus('🔄 画像を確認しています...', 'loading')
    
    // 非表示のimg要素で画像読み込みをテスト
    this.urlPreviewTarget.src = url
    this.urlPreviewTarget.onload = () => {
      this.showUrlStatus('✅ 画像を確認できました', 'success')
      this.urlPreviewTarget.classList.remove('hidden')
    }
    this.urlPreviewTarget.onerror = () => {
      this.showUrlStatus('❌ 画像が読み込めません。URLを確認してください', 'error')
      this.urlPreviewTarget.classList.add('hidden')
    }
  }

  // URLの基本形式チェック
  isValidUrl(url) {
    try {
      const urlObj = new URL(url)
      return ['http:', 'https:'].includes(urlObj.protocol)
    } catch {
      return false
    }
  }

  // URL検証状態表示
  showUrlStatus(message, type) {
    this.urlStatusTarget.textContent = message
    this.urlStatusTarget.className = this.getStatusClass(type)
  }

  // 状態別CSSクラス
  getStatusClass(type) {
    const baseClass = 'text-sm mt-2 px-3 py-2 rounded-lg'
    switch (type) {
      case 'success':
        return `${baseClass} text-green-700 bg-green-50 border border-green-200`
      case 'error':
        return `${baseClass} text-red-700 bg-red-50 border border-red-200`
      case 'loading':
        return `${baseClass} text-orange-700 bg-orange-50 border border-orange-200`
      default:
        return `${baseClass} text-gray-700 bg-gray-50 border border-gray-200`
    }
  }

  // URLプレビューをクリア
  clearUrlPreview() {
    this.urlPreviewTarget.classList.add('hidden')
    this.urlStatusTarget.textContent = ''
    this.urlStatusTarget.className = ''
  }
}
