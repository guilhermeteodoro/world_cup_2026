import { Controller } from "@hotwired/stimulus"

// General-purpose UI state persistence via sessionStorage.
// Observes a sibling Stimulus controller's value and restores it on connect.
//
// Usage:
//   data-controller="ruby-ui--collapsible ui-state"
//   data-ui-state-key-value="unique-key"
//   data-ui-state-attr-value="data-ruby-ui--collapsible-open-value"
//   data-ui-state-restore-method-value="open"   (optional: method to call when true)
//   data-ui-state-close-method-value="close"    (optional: method to call when false)
//   data-ui-state-controller-value="ruby-ui--collapsible" (sibling controller identifier)

export default class extends Controller {
  static values = {
    key: String,
    attr: String,
    controller: { type: String, default: "" },
    restoreMethod: { type: String, default: "" },
    closeMethod: { type: String, default: "" }
  }

  connect() {
    this.#restore()
    this.observer = new MutationObserver(() => this.#persist())
    this.observer.observe(this.element, { attributes: true, attributeFilter: [this.attrValue] })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  #restore() {
    const stored = sessionStorage.getItem(this.#storageKey)
    if (stored === null) return

    const sibling = this.#siblingController
    if (!sibling) return

    const isOpen = stored === "true"
    if (isOpen && this.restoreMethodValue) {
      sibling[this.restoreMethodValue]()
    } else if (!isOpen && this.closeMethodValue) {
      sibling[this.closeMethodValue]()
    }
  }

  #persist() {
    const value = this.element.getAttribute(this.attrValue)
    if (value !== null) {
      sessionStorage.setItem(this.#storageKey, value)
    }
  }

  get #storageKey() {
    return `ui-state:${this.keyValue}`
  }

  get #siblingController() {
    if (!this.controllerValue) return null
    return this.application.getControllerForElementAndIdentifier(this.element, this.controllerValue)
  }
}
