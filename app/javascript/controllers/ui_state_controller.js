import { Controller } from "@hotwired/stimulus"

// General-purpose UI state persistence via sessionStorage.
// Observes a sibling Stimulus controller's value and restores it on connect.
//
// Usage:
//   data-controller="ruby-ui--collapsible ui-state"
//   data-ui-state-key-value="unique-key"
//   data-ui-state-attr-value="data-ruby-ui--collapsible-open-value"
//   data-ui-state-controller-value="ruby-ui--collapsible"
//   data-ui-state-restore-method-value="open"   (method to call when stored value is "true")
//   data-ui-state-close-method-value="close"    (method to call when stored value is "false")

export default class extends Controller {
  static values = {
    key: String,
    attr: String,
    controller: { type: String, default: "" },
    restoreMethod: { type: String, default: "" },
    closeMethod: { type: String, default: "" }
  }

  connect() {
    this.restoring = false
    // Defer restore so sibling controllers finish connecting first
    this.frame = requestAnimationFrame(() => {
      this.#restore()
      this.observer = new MutationObserver(() => {
        if (!this.restoring) this.#persist()
      })
      this.observer.observe(this.element, { attributes: true, attributeFilter: [this.attrValue] })
    })
  }

  disconnect() {
    if (this.frame) cancelAnimationFrame(this.frame)
    if (this.observer) this.observer.disconnect()
  }

  #restore() {
    const stored = sessionStorage.getItem(this.#storageKey)
    if (stored === null) return

    const sibling = this.#siblingController
    if (!sibling) return

    const isOpen = stored === "true"
    const current = this.element.getAttribute(this.attrValue)
    if (current === stored) return // already matches, no-op

    this.restoring = true
    if (isOpen && this.restoreMethodValue) {
      sibling[this.restoreMethodValue]()
    } else if (!isOpen && this.closeMethodValue) {
      sibling[this.closeMethodValue]()
    }
    // Allow the attribute change from restore to settle before observing
    requestAnimationFrame(() => { this.restoring = false })
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
