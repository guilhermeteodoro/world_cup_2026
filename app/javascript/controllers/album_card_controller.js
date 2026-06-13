import { Controller } from "@hotwired/stimulus"
import { post, patch, destroy } from "@rails/request.js"

export default class extends Controller {
  static targets = ["cardGroup", "topCard", "placeholder", "badge", "actions"]
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
      // Determine state based on click position
      const rect = this.element.getBoundingClientRect()
      const x = event.clientX - rect.left
      const y = event.clientY - rect.top
      const isTopRight = x > rect.width * 0.5 && y < rect.height * 0.5
      const state = isTopRight ? "to_be_glued" : "glued"

      if (state === "to_be_glued") {
        this.toBeGluedValue = true
        this.#ensureActions()
      } else {
        this.gluedValue = true
        this.copiesValue = 0
        this.#ensureActions()
      }
      this.#render()

      post(this.createUrlValue, { body: { sticker_id: this.stickerIdValue, state } })
        .then(async (response) => {
          if (response.ok) {
            const data = await response.json
            this.userStickerIdValue = data.id
            this.#updateUrls(data.id)
            if (state === "to_be_glued") {
              this.#incrementNewCount()
            }
          } else {
            this.gluedValue = false
            this.toBeGluedValue = false
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
    this.toBeGluedValue = false
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
    const group = this.hasCardGroupTarget ? this.cardGroupTarget : this.element
    const card = this.hasTopCardTarget ? this.topCardTarget : this.element
    const color = this.colorValue

    if (this.gluedValue || this.toBeGluedValue) {
      // Card group visible
      group.classList.remove("opacity-0", "pointer-events-none")
      group.classList.add("opacity-100")

      // Text styling on topCard
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

      // to_be_glued visual: folded corner + offset on the group
      if (this.toBeGluedValue) {
        group.classList.add("folded-corner")
        group.style.transform = "rotate(2deg) translate(2px, 2px)"
      } else {
        group.classList.remove("folded-corner")
        group.style.transform = ""
      }
    } else {
      // Card group hidden — placeholder shows through
      group.classList.add("opacity-0", "pointer-events-none")
      group.classList.remove("opacity-100", "folded-corner")
      group.style.transform = ""
      card.classList.remove("text-white", "text-gray-900", "[text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]", "[text-shadow:_0_1px_0_rgba(255,255,255,0.3)]", "foil-card")
      card.style.backgroundColor = ""
    }

    if (this.hasBadgeTarget) {
      if (this.copiesValue > 0) {
        this.badgeTarget.textContent = this.copiesValue
        this.badgeTarget.classList.remove("hidden")
        group.style.filter = "drop-shadow(3px 3px 0 #374151)"
      } else {
        this.badgeTarget.classList.add("hidden")
        group.style.filter = ""
      }
    }

    if (this.hasActionsTarget) {
      if (this.gluedValue || this.toBeGluedValue) {
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
    const btnClass = `h-8 sm:h-6 rounded-lg ${btnColor} text-xs font-bold active:scale-95 cursor-pointer`

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
    // Insert before the badge span in topCard
    const topCard = this.hasTopCardTarget ? this.topCardTarget : this.element
    const badge = topCard.querySelector('[data-album-card-target="badge"]')
    topCard.insertBefore(wrapper, badge)
  }
}
