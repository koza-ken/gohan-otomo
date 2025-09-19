import BaseImageController from "./base_image_controller.js"

// Connects to data-controller="image-preview"
export default class extends BaseImageController {
  static targets = ["input", "preview", "urlInput", "urlPreview", "urlStatus"]
  
  connect() {
    // Controller initialization
  }
  
  async preview(event) {
    const file = event.target.files[0]

    if (file && file.type.startsWith('image/')) {
      try {
        const dataUrl = await this.readFileAsDataURL(file)
        this.previewTarget.src = dataUrl
        this.toggleElementVisibility(this.previewTarget, true)
      } catch (error) {
        console.error('File preview error:', error)
        this.toggleElementVisibility(this.previewTarget, false)
      }
    } else {
      // 画像ファイルでない場合はプレビューを隠す
      this.toggleElementVisibility(this.previewTarget, false)
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

  // ベースクラスのcreatePlaceholderを使用（メソッド削除）

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
  async testImageUrl(url) {
    this.showUrlStatus('🔄 画像を確認しています...', 'loading')

    try {
      const imageInfo = await this.testImageLoad(url)
      this.urlPreviewTarget.src = url
      this.showUrlStatus('✅ 画像を確認できました', 'success')
      this.toggleElementVisibility(this.urlPreviewTarget, true)
    } catch (error) {
      this.showUrlStatus('❌ 画像が読み込めません。URLを確認してください', 'error')
      this.toggleElementVisibility(this.urlPreviewTarget, false)
    }
  }

  // URL検証状態表示
  showUrlStatus(message, type) {
    this.urlStatusTarget.textContent = message
    this.urlStatusTarget.className = this.getStatusClass(type)
  }

  // URLプレビューをクリア
  clearUrlPreview() {
    this.toggleElementVisibility(this.urlPreviewTarget, false)
    this.urlStatusTarget.textContent = ''
    this.urlStatusTarget.className = ''
  }
}
