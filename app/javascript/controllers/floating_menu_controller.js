import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "plusIcon", "closeIcon"]

  connect() {
    // ページ外クリックでメニューを閉じる
    this.boundCloseMenu = this.closeMenu.bind(this)
    document.addEventListener("click", this.boundCloseMenu)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseMenu)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.openMenu()
    } else {
      this.closeMenu()
    }
  }

  openMenu() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.classList.add("bg-orange-600")
    // ＋を隠して×を表示
    this.plusIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
  }

  closeMenu(event) {
    // イベントが存在し、かつクリックターゲットがこのコントローラー内の要素の場合は閉じない
    if (event && this.element.contains(event.target)) {
      return
    }

    this.menuTarget.classList.add("hidden")
    this.buttonTarget.classList.remove("bg-orange-600")
    // ×を隠して＋を表示
    this.plusIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }
}
