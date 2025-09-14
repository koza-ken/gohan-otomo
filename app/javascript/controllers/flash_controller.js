import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    const timeout = this.hasTimeoutValue ? this.timeoutValue : 3000 // デフォルト4秒

    // 要素が表示されたらタイマーを開始
    setTimeout(() => {
      this.autoHideTimer = setTimeout(() => {
        this.hide()
      }, timeout)
    }, 100) // アニメーション完了後にタイマー開始

    // クリックで手動削除を可能にする（メッセージ全体とXボタン）
    this.element.addEventListener('click', (e) => {
      this.hide()
    })
  }

  disconnect() {
    // コントローラーが削除される際にタイマーをクリア
    if (this.autoHideTimer) {
      clearTimeout(this.autoHideTimer)
    }
  }

  hide() {
    // すでに非表示処理中の場合は何もしない
    if (this.isHiding) return
    this.isHiding = true

    // 上にスライドアウトするアニメーション
    this.element.style.transition = 'all 0.3s ease-in'
    this.element.style.transform = 'translateY(-100%)'
    this.element.style.opacity = '0'

    // アニメーション完了後に要素を削除
    setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }
}
