import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn"]

  #expanded = false

  toggleAll() {
    this.#expanded = !this.#expanded

    const collapsibles = this.element.querySelectorAll('[data-controller="ui-state"]')
    collapsibles.forEach(el => {
      const controller = this.application.getControllerForElementAndIdentifier(el, "ui-state")
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
