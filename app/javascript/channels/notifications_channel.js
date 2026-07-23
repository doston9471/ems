import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  received(data) {
    const badge = document.getElementById("notification-badge")
    if (!badge) return

    const count = Number(data.unread_count || 0)
    if (count > 0) {
      badge.textContent = count > 99 ? "99+" : String(count)
      badge.classList.remove("hidden")
    } else {
      badge.textContent = ""
      badge.classList.add("hidden")
    }

    badge.dataset.pulse = "true"
    window.setTimeout(() => { badge.dataset.pulse = "false" }, 600)
  }
})
