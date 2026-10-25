import { Controller } from "@hotwired/stimulus"

// Adds and removes the fields of nested records in a form (accepts_nested_attributes_for).
//
// Add:    a link carrying the new record's fields as a template, with a placeholder
//         child index that is replaced by a unique number on each click.
// Remove: a link right after the record's hidden _destroy field; marks the record
//         for deletion and hides its fields.
export default class extends Controller {
  static values = { template: String, placeholder: String, container: String }

  add(event) {
    event.preventDefault()
    const html = this.templateValue.replaceAll(this.placeholderValue, Date.now().toString())
    const container = this.containerValue && document.querySelector(this.containerValue)

    if (container) {
      container.insertAdjacentHTML("beforeend", html)
    } else {
      this.element.insertAdjacentHTML("beforebegin", html)
    }
  }

  remove(event) {
    event.preventDefault()
    const destroyField = this.element.previousElementSibling
    if (destroyField?.matches('input[type="hidden"][name$="[_destroy]"]')) destroyField.value = "1"

    const record = this.element.closest("fieldset, tr")
    if (record) record.style.display = "none"
  }
}
