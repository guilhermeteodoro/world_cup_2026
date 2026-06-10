import CollapsibleController from "./ruby_ui/collapsible_controller"

// Extends the RubyUI collapsible to persist open/closed state in sessionStorage.
// Use data-controller="persistent-collapsible" instead of "ruby-ui--collapsible".
// Add data-persistent-collapsible-key-value="unique-key" to identify.

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
        // Override the HTML attribute before parent reads it
        this.element.setAttribute(
          `data-persistent-collapsible-open-value`,
          stored
        )
        // Stimulus re-reads the attribute for openValue
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
