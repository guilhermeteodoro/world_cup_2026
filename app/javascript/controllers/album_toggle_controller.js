import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn"]

  #expanded = false

  toggleAll() {
    this.#expanded = !this.#expanded

    const collapsibles = this.element.querySelectorAll('[data-controller="ruby-ui--collapsible"]')
    collapsibles.forEach(el => {
      const controller = this.application.getControllerForElementAndIdentifier(el, "ruby-ui--collapsible")
      if (controller) {
        this.#expanded ? controller.open() : controller.close()
      }
    })

    this.#updateLabel()
  }

  #updateLabel() {
    if (this.hasBtnTarget) {
      this.btnTarget.textContent = this.#expanded
        ? this.btnTarget.dataset.collapseText
        : this.btnTarget.dataset.expandText
    }
  }
}
