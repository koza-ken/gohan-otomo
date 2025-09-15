import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="unified-preview"
export default class extends Controller {
  // 指定した要素を参照する
  static targets = [
    "activePreviewArea", "activePreviewImage", "activeImageInfo",
    "placeholder", "urlInput", "fileInput", "urlSection", "fileSection", "imageSourceRadio", "fileLabel", "clearButton"
  ]

  connect() {
    // Unified preview controller connected
    // 画像ソース（urlかfile）を保持
    this.currentImageSource = 'url' // デフォルトはURL画像

    // 初期状態をチェック（編集ページなどで既に値がある場合）
    this.checkInitialState()
  }

  // ラジオボタンで画像ソースを切り替えたときに呼ばれる
  switchImageSource(event) {
    const selectedSource = event.target.value
    // 画像ソース切り替え

    this.currentImageSource = selectedSource
    // 入力フォームを切り替え
    this.updateFormSections(selectedSource)
    // 選択に応じてプレビューを更新
    this.updatePreviewForCurrentSource()
  }

  // フォームセクションの表示制御
  updateFormSections(selectedSource) {
    // すべて非表示に
    if (this.hasUrlSectionTarget) this.urlSectionTarget.classList.add('hidden')
    if (this.hasFileSectionTarget) this.fileSectionTarget.classList.add('hidden')

    // 選択されたセクションを表示
    switch (selectedSource) {
      case 'url':
        if (this.hasUrlSectionTarget) this.urlSectionTarget.classList.remove('hidden')
        break
      case 'file':
        if (this.hasFileSectionTarget) this.fileSectionTarget.classList.remove('hidden')
        break
    }
  }

  // 現在の選択に応じてプレビュー更新
  updatePreviewForCurrentSource() {
    switch (this.currentImageSource) {
      case 'url':
        if (this.hasUrlInputTarget && this.urlInputTarget.value.trim()) {
          this.updateUrlPreview({ target: this.urlInputTarget })
        } else {
          this.showPlaceholder()
        }
        break
      case 'file':
        if (this.hasFileInputTarget && this.fileInputTarget.files[0]) {
          this.updateFilePreview({ target: this.fileInputTarget })
        } else {
          this.showPlaceholder()
        }
        break
    }
  }

  // 初期状態をチェック
  checkInitialState() {
    // 編集ページで既に値がある場合の自動選択
    if (this.hasUrlInputTarget && this.urlInputTarget.value.trim()) {
      // 初期URL検出
      this.setImageSource('url')
      this.updateUrlPreview({ target: this.urlInputTarget })
    } else if (this.hasFileInputTarget && this.fileInputTarget.files[0]) {
      // 初期ファイル検出
      this.setImageSource('file')
      this.updateFilePreview({ target: this.fileInputTarget })
    } else {
      // デフォルトはURL画像選択、プレースホルダー表示
      // 初期状態: URL画像選択デフォルト
      this.setImageSource('url')
      this.showPlaceholder()
    }
  }

  // ラジオボタンの選択状態を設定
  setImageSource(source) {
    this.currentImageSource = source

    // ラジオボタンの状態を更新
    this.imageSourceRadioTargets.forEach(radio => {
      radio.checked = (radio.value === source)
    })

    // フォームセクションを更新
    this.updateFormSections(source)
  }

  // URL画像のプレビュー更新
  updateUrlPreview(event) {
    const url = event.target.value.trim()

    if (!url) {
      // URLが空の場合、URL画像プレビューを隠す
      this.hideUrlPreview()
      this.checkPlaceholderDisplay()
      return
    }

    // URLの基本形式をチェック
    if (!this.isValidUrl(url)) {
      this.showUrlError('正しいURL形式で入力してください')
      return
    }

    // 画像の実際の読み込みテスト
    this.loadUrlImage(url)
  }

  // ファイルアップロードのプレビュー更新
  updateFilePreview(event) {
    const file = event.target.files[0]

    if (!file) {
      // ファイルが選択されていない場合、ラベルをデフォルトに戻す
      this.updateFileLabel('ファイルを選択')
      this.showPlaceholder()
      return
    }

    if (!file.type.startsWith('image/')) {
      this.updateFileLabel('ファイルを選択')
      this.showFileError('画像ファイルを選択してください')
      return
    }

    // ファイルサイズチェック（10MB）
    if (file.size > 10 * 1024 * 1024) {
      this.updateFileLabel('ファイルを選択')
      this.showFileError('ファイルサイズは10MB以下にしてください')
      return
    }

    // ファイル名をラベルに表示
    this.updateFileLabel(file.name)
    this.loadFileImage(file)
  }

  // URL画像の読み込み
  loadUrlImage(url) {
    this.showUrlLoading('URL画像を確認しています...')

    // 新しいImage要素で画像読み込みをテスト
    const testImg = new Image()

    testImg.onload = () => {
      this.showUrlPreview(url, `URL画像 (${testImg.naturalWidth}×${testImg.naturalHeight}px)`)
    }

    testImg.onerror = () => {
      this.showUrlError('画像が読み込めません。URLを確認してください')
    }

    testImg.src = url
  }

  // ファイル画像の読み込み
  loadFileImage(file) {
    this.showFileLoading('ファイル画像を読み込んでいます...')

    const reader = new FileReader()

    reader.onload = (e) => {
      const fileSize = this.formatFileSize(file.size)
      this.showFilePreview(e.target.result, `ファイル画像 (${file.name}, ${fileSize})`)
    }

    reader.onerror = () => {
      this.showFileError('ファイルの読み込みに失敗しました')
    }

    reader.readAsDataURL(file)
  }

  // URL画像プレビューを表示
  showUrlPreview(url, info) {
    this.activePreviewImageTarget.src = url
    this.activeImageInfoTarget.textContent = info
    this.showActivePreview()
  }

  // ファイル画像プレビューを表示
  showFilePreview(dataUrl, info) {
    this.activePreviewImageTarget.src = dataUrl
    this.activeImageInfoTarget.textContent = info
    this.showActivePreview()
  }

  // アクティブプレビューを表示
  showActivePreview() {
    this.activePreviewAreaTarget.classList.remove('hidden')
    this.placeholderTarget.classList.add('hidden')
    // 削除ボタンも表示
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.remove('hidden')
    }
  }

  // プレースホルダーを表示
  showPlaceholder() {
    this.activePreviewAreaTarget.classList.add('hidden')
    this.placeholderTarget.classList.remove('hidden')
    // 削除ボタンも隠す
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.add('hidden')
    }
  }

  // URLローディング表示
  showUrlLoading(message) {
    this.activeImageInfoTarget.textContent = message
    this.showActivePreview()
  }

  // ファイルローディング表示
  showFileLoading(message) {
    this.activeImageInfoTarget.textContent = message
    this.showActivePreview()
  }

  // URLエラー表示
  showUrlError(message) {
    this.activeImageInfoTarget.textContent = message
    this.showActivePreview()
  }

  // ファイルエラー表示
  showFileError(message) {
    this.activeImageInfoTarget.textContent = message
    this.showActivePreview()
  }

  // アクティブ画像削除
  clearActiveImage() {
    switch (this.currentImageSource) {
      case 'url':
        if (this.hasUrlInputTarget) {
          this.urlInputTarget.value = ''
        }
        break
      case 'file':
        if (this.hasFileInputTarget) {
          this.fileInputTarget.value = ''
          this.updateFileLabel('ファイルを選択')
        }
        break
    }
    this.showPlaceholder()
  }

  // URL画像削除
  clearUrlImage() {
    if (this.hasUrlInputTarget) {
      this.urlInputTarget.value = ''
    }
    if (this.currentImageSource === 'url') {
      this.showPlaceholder()
    }
  }

  // ファイル画像削除
  clearFileImage() {
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ''
      this.updateFileLabel('ファイルを選択')
    }
    if (this.currentImageSource === 'file') {
      this.showPlaceholder()
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

  // ファイルサイズのフォーマット
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'

    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  // ファイルラベルの更新
  updateFileLabel(text) {
    if (this.hasFileLabelTarget) {
      this.fileLabelTarget.textContent = text
    }
  }
}
