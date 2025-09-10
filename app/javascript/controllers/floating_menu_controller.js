import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "icon"]
  
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
    this.iconTarget.style.transform = "rotate(45deg)"
    this.buttonTarget.classList.add("bg-orange-600")
  }
  
  closeMenu(event) {
    // イベントが存在し、かつクリックターゲットがこのコントローラー内の要素の場合は閉じない
    if (event && this.element.contains(event.target)) {
      return
    }
    
    this.menuTarget.classList.add("hidden")
    this.iconTarget.style.transform = "rotate(0deg)"
    this.buttonTarget.classList.remove("bg-orange-600")
  }
}