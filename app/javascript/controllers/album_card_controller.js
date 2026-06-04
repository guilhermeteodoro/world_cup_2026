import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "badge", "actions"]
  static values = {
    stickerId: Number,
    userStickerId: Number,
    copies: Number,
    glued: Boolean,
    color: String,
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

    fetch(this.createUrlValue, {
      method: "POST",
      headers: this.#headers(),
      body: JSON.stringify({ sticker_id: this.stickerIdValue })
    })
      .then(res => res.json())
      .then(data => {
        this.userStickerIdValue = data.id
        this.#updateUrls(data.id)
      })
      .catch(() => {
        this.gluedValue = false
        this.#render()
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

    fetch(this.destroyUrlValue, {
      method: "DELETE",
      headers: this.#headers()
    }).catch(() => {
      this.gluedValue = true
      this.#render()
    })
  }

  #debouncedSync() {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: this.#headers(),
        body: JSON.stringify({ copies: this.copiesValue })
      }).catch(() => {
        // TODO: revert on failure
      })
    }, 500)
  }

  #updateUrls(id) {
    const base = this.createUrlValue.replace(/\/$/, "")
    this.updateUrlValue = `${base}/${id}`
    this.destroyUrlValue = `${base}/${id}`
  }

  #render() {
    const card = this.element

    if (this.gluedValue) {
      card.classList.remove("text-gray-600", "border-gray-300", "bg-gray-50")
      card.classList.add("text-white", "border-transparent")
      card.style.backgroundColor = this.colorValue
    } else {
      card.classList.add("text-gray-600", "border-gray-300", "bg-gray-50")
      card.classList.remove("text-white", "border-transparent")
      card.style.backgroundColor = ""
    }

    if (this.hasBadgeTarget) {
      if (this.copiesValue > 0) {
        this.badgeTarget.textContent = this.copiesValue
        this.badgeTarget.classList.remove("hidden")
      } else {
        this.badgeTarget.classList.add("hidden")
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

  #headers() {
    return {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    }
  }
}
