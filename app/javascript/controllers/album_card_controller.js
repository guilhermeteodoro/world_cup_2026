import { Controller } from "@hotwired/stimulus"
import { post, patch, destroy } from "@rails/request.js"

export default class extends Controller {
  static targets = ["card", "badge", "actions"]
  static values = {
    stickerId: Number,
    userStickerId: Number,
    copies: Number,
    glued: Boolean,
    color: String,
    foil: Boolean,
    createUrl: String,
    updateUrl: String,
    destroyUrl: String
  }

  #debounceTimer = null

  connect() {
    this.#render()
  }

  glue(event) {
    if (this.gluedValue) return
    if (event.target.closest('[data-album-card-target="actions"]')) return

    this.gluedValue = true
    this.copiesValue = 0
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

    if (this.gluedValue) {
      card.classList.add("is-glued")
      if (this.foilValue) {
        card.classList.add("foil-card")
      } else {
        card.classList.remove("foil-card")
      }
      card.style.backgroundColor = color
    } else {
      card.classList.remove("is-glued", "foil-card")
      card.style.backgroundColor = ""
    }

    if (this.hasBadgeTarget) {
      if (this.copiesValue > 0) {
        this.badgeTarget.textContent = this.copiesValue
        this.badgeTarget.classList.remove("hidden")
        card.classList.add("has-copies")
      } else {
        this.badgeTarget.classList.add("hidden")
        card.classList.remove("has-copies")
      }
    }

    if (this.hasActionsTarget) {
      if (this.gluedValue) {
        this.actionsTarget.classList.remove("invisible")
      } else {
        this.actionsTarget.classList.add("invisible")
      }
    }
  }
}
