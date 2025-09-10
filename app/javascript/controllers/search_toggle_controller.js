import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-toggle"
export default class extends Controller {
  static targets = ["form", "button"]

  connect() {
    // 何もしない（HTML初期状態に任せる）
  }

  toggle() {
    // シンプル：hiddenクラスの有無で判定・切り替え
    if (this.formTarget.classList.contains("hidden")) {
      // 表示する
      this.formTarget.classList.remove("hidden")
      this.formTarget.classList.add("animate-fade-in")
      this.buttonTarget.setAttribute("aria-expanded", "true")
      this.updateButtonIcon(true)
    } else {
      // 非表示にする
      this.formTarget.classList.add("hidden")
      this.formTarget.classList.remove("animate-fade-in")
      this.buttonTarget.setAttribute("aria-expanded", "false")
      this.updateButtonIcon(false)
    }
  }

  updateButtonIcon(isOpen) {
    const searchIcon = this.buttonTarget.querySelector("[data-search-icon]")
    const closeIcon = this.buttonTarget.querySelector("[data-close-icon]")
    
    if (isOpen) {
      searchIcon.classList.add("hidden")
      closeIcon.classList.remove("hidden")
    } else {
      searchIcon.classList.remove("hidden")
      closeIcon.classList.add("hidden")
    }
  }

  // ウィンドウリサイズ時の処理
  handleResize = () => {
    if (window.innerWidth >= 640) { // smブレークポイント
      // PC/タブレット：トグル状態をリセット
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }

  // リサイズイベントリスナーを設定
  initialize() {
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }
}