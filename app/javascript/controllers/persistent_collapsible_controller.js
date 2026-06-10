import CollapsibleController from "./ruby_ui/collapsible_controller"

// Extends the RubyUI collapsible to persist open/closed state in sessionStorage.
// Drop-in replacement: register under "ruby-ui--collapsible".
// Add data-ruby-ui--collapsible-key-value="unique-key" to any Collapsible to enable persistence.
// Without a key, behaves identically to the base controller.

export default class extends CollapsibleController {
  static values = {
    ...CollapsibleController.values,
    key: { type: String, default: "" }
  }

  connect() {
    this.connected = false
    if (this.keyValue) {
      const stored = sessionStorage.getItem(`ui-state:${this.keyValue}`)
      if (stored !== null) {
        this.openValue = stored === "true"
      }
    }
    super.connect()
    this.connected = true
  }

  openValueChanged(isOpen, wasOpen) {
    super.openValueChanged(isOpen, wasOpen)
    if (this.connected && this.keyValue) {
      sessionStorage.setItem(`ui-state:${this.keyValue}`, isOpen)
    }
  }
}
