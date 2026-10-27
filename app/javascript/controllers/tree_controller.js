import { Controller } from "@hotwired/stimulus"

// Collapsible nested list (the data catalog's study/theme tree). Each <li> holding a
// nested <ul> gets an expand/contract handle in front of its label; nested lists start
// closed. Items already set up (a page restored from Turbo's cache) keep their state.
export default class extends Controller {
  static targets = ["list", "toggleAll"]

  listTargetConnected(list) {
    for (const item of list.querySelectorAll("li")) {
      if (item.classList.contains("root") || !item.querySelector(":scope > ul")) continue

      item.classList.add("root")
      item.prepend(this.handleFor(item))
      this.setOpen(item, false)
    }
  }

  toggle(event) {
    event.preventDefault()
    const item = event.currentTarget.parentElement
    this.setOpen(item, !item.classList.contains("expanded"))
  }

  toggleAll(event) {
    event.preventDefault()
    const open = this.items.some((item) => !item.classList.contains("expanded"))
    this.items.forEach((item) => this.setOpen(item, open))
    this.toggleAllTargets.forEach((link) => (link.textContent = open ? "[Collapse All]" : "[Expand All]"))
  }

  // private

  get items() {
    return this.listTargets.flatMap((list) => [...list.querySelectorAll("li.root")])
  }

  // Wraps the item's label (its first node) so a click on the label toggles the item
  handleFor(item) {
    const handle = document.createElement("span")
    handle.className = "expand"
    handle.setAttribute("role", "button")
    handle.tabIndex = 0
    handle.dataset.action = "click->tree#toggle keydown.enter->tree#toggle keydown.space->tree#toggle"
    handle.append(item.firstChild)
    return handle
  }

  setOpen(item, open) {
    item.classList.toggle("expanded", open)
    const handle = item.querySelector(":scope > .expand")
    handle.classList.toggle("contract", open)
    handle.setAttribute("aria-expanded", open)
    item.querySelectorAll(":scope > ul").forEach((list) => (list.hidden = !open))
  }
}
