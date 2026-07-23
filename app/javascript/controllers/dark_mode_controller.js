import { Controller } from "@hotwired/stimulus"

// Toggles `dark` on <html> and persists preference in localStorage.
export default class extends Controller {
  static targets = ["label"]

  connect() {
    this.syncLabel()
  }

  toggle() {
    const root = document.documentElement
    const next = !root.classList.contains("dark")
    root.classList.toggle("dark", next)
    try {
      localStorage.setItem("ems-theme", next ? "dark" : "light")
    } catch (e) {}
    this.syncLabel()
  }

  syncLabel() {
    if (!this.hasLabelTarget) return
    const dark = document.documentElement.classList.contains("dark")
    this.labelTarget.textContent = dark ? "Light" : "Dark"
  }
}
