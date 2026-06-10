import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "label", "autoOption", "defaultOption"]

  switchToAuto() {
    this.formTarget.action = this.formTarget.dataset.autoAction
    this.labelTarget.textContent = this.labelTarget.dataset.autoLabel
    this.autoOptionTarget.classList.add("hidden")
    this.defaultOptionTarget.classList.remove("hidden")
    this.#closeDropdown()
  }

  switchToDefault() {
    this.formTarget.action = this.formTarget.dataset.defaultAction
    this.labelTarget.textContent = this.labelTarget.dataset.defaultLabel
    this.defaultOptionTarget.classList.add("hidden")
    this.autoOptionTarget.classList.remove("hidden")
    this.#closeDropdown()
  }

  #closeDropdown() {
    // Find the ruby-ui--dropdown-menu controller on the nested element and close it
    const dropdownEl = this.element.querySelector("[data-controller*='ruby-ui--dropdown-menu']")
    if (dropdownEl) {
      const controller = this.application.getControllerForElementAndIdentifier(dropdownEl, "ruby-ui--dropdown-menu")
      if (controller) controller.close()
    }
  }
}
