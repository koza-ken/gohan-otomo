import { Controller } from "@hotwired/stimulus"

// 画像関連機能の共通ベースクラス
export default class extends Controller {

  // URL形式の基本バリデーション
  isValidUrl(url) {
    try {
      const urlObj = new URL(url)
      return ['http:', 'https:'].includes(urlObj.protocol)
    } catch {
      return false
    }
  }

  // ファイルサイズのフォーマット
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'

    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  // 画像読み込みテスト用のPromiseベースメソッド
  testImageLoad(url) {
    return new Promise((resolve, reject) => {
      const testImg = new Image()

      testImg.onload = () => {
        resolve({
          width: testImg.naturalWidth,
          height: testImg.naturalHeight,
          url: url
        })
      }

      testImg.onerror = () => {
        reject(new Error('Image load failed'))
      }

      testImg.src = url
    })
  }

  // ファイル画像読み込み用のPromiseベースメソッド
  readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()

      reader.onload = (e) => {
        resolve(e.target.result)
      }

      reader.onerror = () => {
        reject(new Error('File read failed'))
      }

      reader.readAsDataURL(file)
    })
  }

  // 画像ファイルの基本バリデーション
  validateImageFile(file, maxSizeBytes = 10 * 1024 * 1024) { // デフォルト10MB
    const errors = []

    if (!file.type.startsWith('image/')) {
      errors.push('画像ファイルを選択してください')
    }

    if (file.size > maxSizeBytes) {
      const maxSizeMB = Math.round(maxSizeBytes / (1024 * 1024))
      errors.push(`ファイルサイズは${maxSizeMB}MB以下にしてください`)
    }

    return {
      isValid: errors.length === 0,
      errors: errors
    }
  }

  // プレースホルダーHTML生成
  createPlaceholder(size = 'medium', message = '画像がありません') {
    const heightClass = size === 'thumbnail' ? 'h-48' : 'h-64 md:h-80'

    return `<div class="flex items-center justify-center ${heightClass} bg-orange-100">
              <img src="/no_image.png" alt="${message}" class="w-full h-full object-contain">
            </div>`
  }

  // 状態メッセージ用のCSSクラス生成
  getStatusClass(type, baseClass = 'text-sm mt-2 px-3 py-2 rounded-lg') {
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

  // 要素の表示/非表示切り替え
  toggleElementVisibility(element, isVisible) {
    if (isVisible) {
      element.classList.remove('hidden')
    } else {
      element.classList.add('hidden')
    }
  }

  // 複数要素への一括操作
  updateMultipleElements(elements, callback) {
    elements.forEach(callback)
  }
}