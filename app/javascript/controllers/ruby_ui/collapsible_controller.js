import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['content', 'icon']
  static values = {
    open: {
      type: Boolean,
      default: false,
    },
  }

  connect() {
    this.openValue ? this.#show(false) : this.#hide(false)
  }

  toggle() {
    this.openValue = !this.openValue
  }

  open() {
    this.openValue = true
  }

  close() {
    this.openValue = false
  }

  openValueChanged(isOpen, wasOpen) {
    if (wasOpen === undefined) return
    isOpen ? this.#show(true) : this.#hide(true)
  }

  #show(animate) {
    if (!this.hasContentTarget) return
    const el = this.contentTarget

    if (animate) {
      el.classList.remove('hidden')
      el.style.height = '0px'
      el.style.overflow = 'hidden'
      void el.offsetHeight
      el.style.transition = 'height 150ms ease-out'
      el.style.height = el.scrollHeight + 'px'
      this.#onTransitionEnd(el, () => {
        el.style.height = ''
        el.style.overflow = ''
        el.style.transition = ''
      })
    } else {
      el.classList.remove('hidden')
    }

    if (this.hasIconTarget) {
      this.iconTarget.style.transform = 'rotate(0deg)'
    }
  }

  #hide(animate) {
    if (!this.hasContentTarget) return
    const el = this.contentTarget

    if (animate) {
      el.style.height = el.scrollHeight + 'px'
      el.style.overflow = 'hidden'
      void el.offsetHeight
      el.style.transition = 'height 150ms ease-out'
      el.style.height = '0px'
      this.#onTransitionEnd(el, () => {
        el.classList.add('hidden')
        el.style.height = ''
        el.style.overflow = ''
        el.style.transition = ''
      })
    } else {
      el.classList.add('hidden')
    }

    if (this.hasIconTarget) {
      this.iconTarget.style.transform = 'rotate(-90deg)'
    }
  }

  #onTransitionEnd(el, callback) {
    const handler = (e) => {
      if (e.target !== el || e.propertyName !== 'height') return
      el.removeEventListener('transitionend', handler)
      callback()
    }
    el.addEventListener('transitionend', handler)
  }
}
