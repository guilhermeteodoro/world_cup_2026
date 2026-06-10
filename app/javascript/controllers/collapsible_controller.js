import { Controller } from "@hotwired/stimulus"

// Simple collapsible with optional sessionStorage persistence.
//
// Usage:
//   data-controller="collapsible"
//   data-collapsible-open-value="true"
//   data-collapsible-key-value="unique-key"  (optional, enables persistence)
//
// Targets:
//   content - the element to show/hide
//   icon    - rotates (0deg open, -90deg closed)

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = {
    open: { type: Boolean, default: true },
    key: { type: String, default: "" }
  }

  connect() {
    if (this.keyValue) {
      const stored = sessionStorage.getItem(`ui-state:${this.keyValue}`)
      if (stored !== null) this.openValue = stored === "true"
    }
    this.#apply(false)
  }

  toggle() {
    this.openValue = !this.openValue
    this.#apply(true)
    if (this.keyValue) {
      sessionStorage.setItem(`ui-state:${this.keyValue}`, this.openValue)
    }
  }

  #apply(animate) {
    const el = this.contentTarget
    if (this.openValue) {
      this.#show(el, animate)
    } else {
      this.#hide(el, animate)
    }
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.openValue ? "rotate(0deg)" : "rotate(-90deg)"
    }
  }

  #show(el, animate) {
    el.classList.remove("hidden")
    if (animate) {
      el.style.height = "0px"
      el.style.overflow = "hidden"
      void el.offsetHeight
      el.style.transition = "height 150ms ease-out"
      el.style.height = `${el.scrollHeight}px`
      this.#onTransitionEnd(el, () => {
        el.style.height = ""
        el.style.overflow = ""
        el.style.transition = ""
      })
    }
  }

  #hide(el, animate) {
    if (animate) {
      el.style.height = `${el.scrollHeight}px`
      el.style.overflow = "hidden"
      void el.offsetHeight
      el.style.transition = "height 150ms ease-out"
      el.style.height = "0px"
      this.#onTransitionEnd(el, () => {
        el.classList.add("hidden")
        el.style.height = ""
        el.style.overflow = ""
        el.style.transition = ""
      })
    } else {
      el.classList.add("hidden")
    }
  }

  #onTransitionEnd(el, callback) {
    const handler = (e) => {
      if (e.target !== el || e.propertyName !== "height") return
      el.removeEventListener("transitionend", handler)
      callback()
    }
    el.addEventListener("transitionend", handler)
  }
}
