import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview"]
  
  connect() {
    console.log("Image preview controller connected!")
  }
  
  preview(event) {
    const file = event.target.files[0]
    
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove('hidden')
      }
      
      reader.readAsDataURL(file)
    } else {
      // 画像ファイルでない場合はプレビューを隠す
      this.previewTarget.classList.add('hidden')
    }
  }
}
