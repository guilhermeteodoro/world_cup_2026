import { Controller } from "@hotwired/stimulus"

// Generic UI state controller with sessionStorage persistence.
//
// Manages boolean states on targets via CSS classes. Other controllers
// can use the static read/write methods for arbitrary persistence.
//
// Usage (collapsible):
//   data-controller="ui-state"
//   data-ui-state-open-value="true"
//   data-ui-state-key-value="unique-key"  (optional — enables persistence)
//
// Targets:
//   content — toggled via "hidden" class + transition classes
//   icon    — rotated via inline transform
//   trigger — gets aria-expanded
//
// Actions:
//   toggle — flips open state

const PREFIX = "ui-state:"

export default class extends Controller {
  static targets = ["content", "icon", "trigger"]
  static values = {
    open: { type: Boolean, default: true },
    key: { type: String, default: "" }
  }

  static read(key, name = "open") {
    return sessionStorage.getItem(`${PREFIX}${key}:${name}`)
  }

  static write(key, name, value) {
    sessionStorage.setItem(`${PREFIX}${key}:${name}`, String(value))
  }

  connect() {
    if (this.keyValue) {
      const stored = sessionStorage.getItem(`${PREFIX}${this.keyValue}:open`)
      if (stored !== null) this.openValue = stored === "true"
    }
    this.#apply()
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }

  open() {
    this.openValue = true
    this.#persist()
    this.#apply()
  }

  close() {
    this.openValue = false
    this.#persist()
    this.#apply()
  }

  #persist() {
    if (this.keyValue) {
      sessionStorage.setItem(`${PREFIX}${this.keyValue}:open`, this.openValue)
    }
  }

  #apply() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.toggle("hidden", !this.openValue)
    }
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.openValue ? "rotate(0deg)" : "rotate(-90deg)"
    }
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", this.openValue)
    }
  }
}
