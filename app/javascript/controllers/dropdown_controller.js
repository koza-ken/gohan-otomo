import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // クリック外でメニューを閉じるためのイベントリスナー
    this.clickOutsideHandler = this.clickOutside.bind(this)
  }

  toggle() {
    const menu = this.menuTarget
    const isVisible = !menu.classList.contains('opacity-0')
    
    if (isVisible) {
      this.hide()
    } else {
      this.show()
    }
  }

  show() {
    const menu = this.menuTarget
    menu.classList.remove('opacity-0', 'invisible', 'translate-y-2')
    menu.classList.add('opacity-100', 'visible', 'translate-y-0')
    
    // 外部クリックリスナーを追加
    document.addEventListener('click', this.clickOutsideHandler)
  }

  hide() {
    const menu = this.menuTarget
    menu.classList.add('opacity-0', 'invisible', 'translate-y-2')
    menu.classList.remove('opacity-100', 'visible', 'translate-y-0')
    
    // 外部クリックリスナーを削除
    document.removeEventListener('click', this.clickOutsideHandler)
  }

  clickOutside(event) {
    // クリックがメニュー外の場合、メニューを閉じる
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }
}