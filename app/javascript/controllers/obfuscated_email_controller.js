import { Controller } from "@hotwired/stimulus"

// Turns an address written as "name at example.org" into a mailto link in the browser,
// so the page source doesn't carry a harvestable address.
export default class extends Controller {
  connect() {
    const [name, at, domain] = this.element.textContent.trim().split(/\s+/)
    if (at !== "at" || !name || !domain) return

    const address = `${name}@${domain}`
    const link = document.createElement("a")
    link.href = `mailto:${address}`
    link.textContent = address
    this.element.replaceChildren(link)
  }
}
