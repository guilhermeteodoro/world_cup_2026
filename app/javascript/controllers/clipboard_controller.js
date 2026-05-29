import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["line"]

  copy() {
    const lines = this.lineTargets.map(el => el.innerText)
    const text = lines.join("\n")
    navigator.clipboard.writeText(text).then(() => {
      const button = this.element.querySelector("[data-copy-button]")
      const original = button.textContent
      button.textContent = "Copied!"
      setTimeout(() => { button.textContent = original }, 2000)
    })
  }
}
