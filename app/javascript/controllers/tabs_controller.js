import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    const param = new URLSearchParams(window.location.search).get("tab")
    if (param) this.activeValue = param
    this.#render()
  }

  switch(event) {
    event.preventDefault()
    this.activeValue = event.currentTarget.dataset.tab
    this.#render()
    const url = new URL(window.location)
    url.searchParams.set("tab", this.activeValue)
    history.replaceState({}, "", url)
  }

  #render() {
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.tab === this.activeValue
      tab.classList.toggle("border-primary", active)
      tab.classList.toggle("text-foreground", active)
      tab.classList.toggle("border-transparent", !active)
      tab.classList.toggle("text-muted-foreground", !active)
    })

    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.tab !== this.activeValue)
    })
  }
}
