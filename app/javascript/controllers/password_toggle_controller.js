import { Controller } from "@hotwired/stimulus"

// パスワード表示切り替え機能
export default class extends Controller {
  static targets = ["password", "icon"]

  connect() {
    console.log("Password toggle controller connected!")
  }

  toggle() {
    const passwordField = this.passwordTarget
    const iconElement = this.iconTarget

    if (passwordField.type === "password") {
      // パスワードを表示
      passwordField.type = "text"
      iconElement.textContent = "🙈"  // 非表示アイコン
    } else {
      // パスワードを非表示
      passwordField.type = "password"
      iconElement.textContent = "👁"  // 表示アイコン
    }
  }
}