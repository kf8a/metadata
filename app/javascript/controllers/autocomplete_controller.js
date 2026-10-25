import { Controller } from "@hotwired/stimulus"

// Offers search suggestions from a JSON endpoint (an array of strings)
// through the input's native <datalist>.
export default class extends Controller {
  static targets = ["input", "list"]
  static values = { url: String, minLength: { type: Number, default: 2 } }

  disconnect() {
    clearTimeout(this.timer)
  }

  suggest() {
    clearTimeout(this.timer)
    const term = this.inputTarget.value.trim()
    if (term.length < this.minLengthValue) return

    this.timer = setTimeout(() => this.load(term), 200)
  }

  async load(term) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("term", term)

    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const suggestions = await response.json()
    this.listTarget.replaceChildren(...suggestions.map((suggestion) => new Option(suggestion, suggestion)))
  }
}
