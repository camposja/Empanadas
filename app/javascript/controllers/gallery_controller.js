import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main"]

  swap(event) {
    const src = event.currentTarget.dataset.src
    if (src && this.hasMainTarget) {
      this.mainTarget.src = src
    }
  }
}
