import { Controller } from "@hotwired/stimulus"

// Records a data request when the user opens the request email to the data owners.
export default class extends Controller {
  static values = { url: String, datatable: Number }

  record() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": token },
      body: new URLSearchParams({ datatable: this.datatableValue }),
      keepalive: true,
    })
  }
}
