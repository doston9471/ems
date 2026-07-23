import { Controller } from "@hotwired/stimulus"

// Keeps My workspace subnav highlight in sync when only #my_content swaps.
export default class extends Controller {
  static targets = ["link"]

  connect() {
    this.sync()
  }

  sync() {
    const path = window.location.pathname.replace(/\/$/, "") || "/"

    this.linkTargets.forEach((link) => {
      const href = new URL(link.href, window.location.origin).pathname.replace(/\/$/, "") || "/"
      let active = path === href

      if (!active && href !== "/my/dashboard" && path.startsWith(`${href}/`)) {
        active = true
      }

      link.classList.toggle("bg-teal-50", active)
      link.classList.toggle("text-teal-800", active)
      link.classList.toggle("text-slate-600", !active)
      link.classList.toggle("hover:bg-slate-100", !active)
    })
  }
}
