import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // トップページ（投稿一覧）でのみモーダルを表示
    const path = window.location.pathname
    const isTopPage = path === '/' || path === '/posts' || path.startsWith('/posts?')

    console.log('Current path:', path, 'Is top page:', isTopPage)

    if (!isTopPage) return

    // 初回アクセス判定（LocalStorageを使用）
    const hasVisited = localStorage.getItem('has_visited_otomo')
    console.log('Has visited:', hasVisited)

    if (!hasVisited) {
      // 初回アクセスの場合、モーダルを表示
      console.log('Showing modal in 500ms')
      setTimeout(() => {
        this.showModal()
      }, 500) // 0.5秒後に表示（ページロード完了待ち）
    }
  }

  showModal() {
    this.modalTarget.classList.remove('hidden')
    // フェードイン効果
    setTimeout(() => {
      this.modalTarget.classList.remove('opacity-0')
      this.modalTarget.classList.add('opacity-100')
    }, 10)

    // bodyのスクロールを無効化
    document.body.style.overflow = 'hidden'
  }

  closeModal() {
    // フェードアウト効果
    this.modalTarget.classList.remove('opacity-100')
    this.modalTarget.classList.add('opacity-0')

    setTimeout(() => {
      this.modalTarget.classList.add('hidden')
      // bodyのスクロールを有効化
      document.body.style.overflow = 'auto'
    }, 300)

    // 訪問済みフラグを設定
    localStorage.setItem('has_visited_otomo', 'true')
  }

  // モーダル外クリックで閉じる
  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.closeModal()
    }
  }
}