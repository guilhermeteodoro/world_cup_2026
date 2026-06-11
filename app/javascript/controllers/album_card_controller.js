import { Controller } from "@hotwired/stimulus"
import { post, patch, destroy } from "@rails/request.js"

export default class extends Controller {
  static targets = ["card", "badge", "actions"]
  static values = {
    stickerId: Number,
    userStickerId: Number,
    copies: Number,
    glued: Boolean,
    toBeGlued: Boolean,
    color: String,
    foil: Boolean,
    darkText: Boolean,
    createUrl: String,
    updateUrl: String,
    destroyUrl: String
  }

  #debounceTimer = null

  connect() {
    this.#render()
  }

  glue(event) {
    if (this.gluedValue && !this.toBeGluedValue) return
    if (event.target.closest('[data-album-card-target="actions"]')) return

    if (this.toBeGluedValue) {
      // Transition to_be_glued → glued
      this.toBeGluedValue = false
      this.gluedValue = true
      this.#ensureActions()
      this.#render()
      this.#decrementNewCount()

      patch(this.updateUrlValue, { body: { state: "glued" } })
        .then(async (response) => {
          if (!response.ok) {
            this.toBeGluedValue = true
            this.#render()
            this.#incrementNewCount()
          }
        })
    } else {
      // Create new glued sticker
      this.gluedValue = true
      this.copiesValue = 0
      this.#ensureActions()
      this.#render()

      post(this.createUrlValue, { body: { sticker_id: this.stickerIdValue } })
        .then(async (response) => {
          if (response.ok) {
            const data = await response.json
            this.userStickerIdValue = data.id
            this.#updateUrls(data.id)
          } else {
            this.gluedValue = false
            this.#render()
          }
        })
    }
  }

  increment(event) {
    event.stopPropagation()
    this.copiesValue++
    this.#render()
    this.#debouncedSync()
  }

  decrement(event) {
    event.stopPropagation()
    if (this.copiesValue > 0) {
      this.copiesValue--
      this.#render()
      this.#debouncedSync()
    } else {
      this.#confirmUnglue()
    }
  }

  #confirmUnglue() {
    if (!confirm("Remove this sticker from your collection?")) return

    this.gluedValue = false
    this.copiesValue = 0
    this.#render()

    destroy(this.destroyUrlValue).catch(() => {
      this.gluedValue = true
      this.#render()
    })
  }

  #debouncedSync() {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      patch(this.updateUrlValue, { body: { copies: this.copiesValue } })
    }, 500)
  }

  #updateUrls(id) {
    const base = this.createUrlValue.replace(/\/$/, "")
    this.updateUrlValue = `${base}/${id}`
    this.destroyUrlValue = `${base}/${id}`
  }

  #render() {
    const card = this.element
    const color = this.colorValue

    if (this.gluedValue || this.toBeGluedValue) {
      card.classList.remove("opacity-50", "cursor-pointer", "text-gray-600", "bg-gray-100", "border-gray-300")
      card.classList.add("opacity-100", "border-gray-700")
      if (this.darkTextValue) {
        card.classList.add("text-gray-900", "[text-shadow:_0_1px_0_rgba(255,255,255,0.3)]")
        card.classList.remove("text-white", "[text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]")
      } else {
        card.classList.add("text-white", "[text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]")
        card.classList.remove("text-gray-900", "[text-shadow:_0_1px_0_rgba(255,255,255,0.3)]")
      }
      if (this.foilValue) {
        card.classList.add("foil-card")
      } else {
        card.classList.remove("foil-card")
      }
      card.style.backgroundColor = color

      // to_be_glued visual: rotated with amber ring
      if (this.toBeGluedValue) {
        card.classList.add("rotate-3", "ring-2", "ring-amber-400")
      } else {
        card.classList.remove("rotate-3", "ring-2", "ring-amber-400")
      }
    } else {
      card.classList.add("opacity-50", "cursor-pointer", "text-gray-600", "bg-gray-100", "border-gray-300")
      card.classList.remove("opacity-100", "text-white", "text-gray-900", "[text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]", "[text-shadow:_0_1px_0_rgba(255,255,255,0.3)]", "foil-card", "border-gray-700", "rotate-3", "ring-2", "ring-amber-400")
      card.style.backgroundColor = ""
    }

    if (this.hasBadgeTarget) {
      if (this.copiesValue > 0) {
        this.badgeTarget.textContent = this.copiesValue
        this.badgeTarget.classList.remove("hidden")
        card.classList.add("shadow-[3px_3px_0_#374151]")
      } else {
        this.badgeTarget.classList.add("hidden")
        card.classList.remove("shadow-[3px_3px_0_#374151]")
      }
    }

    if (this.hasActionsTarget) {
      if (this.gluedValue) {
        this.actionsTarget.removeAttribute("hidden")
      } else {
        this.actionsTarget.setAttribute("hidden", "")
      }
    }
  }

  #findNewCountEl() {
    // Walk up to the collapsible wrapper, then find the new count span in its trigger
    const section = this.element.closest('[data-controller="ui-state"]')
    return section?.querySelector('[data-new-count]')
  }

  #decrementNewCount() {
    const el = this.#findNewCountEl()
    if (!el) return
    const match = el.textContent.match(/\d+/)
    if (!match) return
    const count = parseInt(match[0]) - 1
    if (count <= 0) {
      el.remove()
    } else {
      el.textContent = el.textContent.replace(/\d+/, count)
    }
  }

  #incrementNewCount() {
    const el = this.#findNewCountEl()
    if (!el) return
    const match = el.textContent.match(/\d+/)
    if (!match) return
    const count = parseInt(match[0]) + 1
    el.textContent = el.textContent.replace(/\d+/, count)
  }

  #ensureActions() {
    if (this.hasActionsTarget) return

    const isDark = this.darkTextValue
    const btnColor = isDark ? "bg-black/20 text-gray-900" : "bg-white/30 text-white"
    const btnClass = `h-6 rounded-lg ${btnColor} text-xs font-bold active:scale-95 cursor-pointer`

    const wrapper = document.createElement("div")
    wrapper.setAttribute("data-album-card-target", "actions")

    const grid = document.createElement("div")
    grid.className = "grid grid-cols-2 gap-1"

    const dec = document.createElement("button")
    dec.type = "button"
    dec.className = btnClass
    dec.setAttribute("data-action", "click->album-card#decrement")
    dec.textContent = "−"

    const inc = document.createElement("button")
    inc.type = "button"
    inc.className = btnClass
    inc.setAttribute("data-action", "click->album-card#increment")
    inc.textContent = "+"

    grid.append(dec, inc)
    wrapper.append(grid)
    // Insert before the badge span
    const badge = this.element.querySelector('[data-album-card-target="badge"]')
    this.element.insertBefore(wrapper, badge)
  }
}
