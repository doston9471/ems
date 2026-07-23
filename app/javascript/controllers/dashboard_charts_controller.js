import { Controller } from "@hotwired/stimulus"

const TEAL = "#0f766e"
const TEAL_SOFT = "#5eead4"
const SLATE = "#334155"
const SLATE_MUTED = "#94a3b8"
const AMBER = "#d97706"
const ROSE = "#e11d48"
const SKY = "#0284c8"

const PALETTE = [TEAL, SLATE, AMBER, SKY, ROSE, TEAL_SOFT, "#64748b", "#0d9488"]

export default class extends Controller {
  static targets = ["department", "status", "attendance", "leave"]
  static values = {
    department: Object,
    status: Object,
    attendance: Object,
    leave: Object
  }

  connect() {
    this.charts = []
    this.renderWhenReady()
  }

  disconnect() {
    this.destroyCharts()
  }

  renderWhenReady(attempts = 0) {
    if (window.Chart) {
      this.renderAll()
      return
    }

    if (attempts > 40) return

    window.setTimeout(() => this.renderWhenReady(attempts + 1), 50)
  }

  renderAll() {
    this.destroyCharts()
    this.charts = []

    if (this.hasDepartmentTarget) {
      this.charts.push(this.renderBar(this.departmentTarget, this.departmentValue, "Employees"))
    }
    if (this.hasStatusTarget) {
      this.charts.push(this.renderDoughnut(this.statusTarget, this.statusValue))
    }
    if (this.hasAttendanceTarget) {
      this.charts.push(this.renderLine(this.attendanceTarget, this.attendanceValue, "Present"))
    }
    if (this.hasLeaveTarget) {
      this.charts.push(this.renderDoughnut(this.leaveTarget, this.leaveValue))
    }

    this.charts = this.charts.filter(Boolean)
  }

  renderBar(canvas, data, label) {
    if (!canvas || !data?.labels?.length) return null

    return new window.Chart(canvas, {
      type: "bar",
      data: {
        labels: data.labels,
        datasets: [{
          label,
          data: data.values,
          backgroundColor: TEAL,
          borderRadius: 4,
          maxBarThickness: 36
        }]
      },
      options: this.baseOptions({
        plugins: { legend: { display: false } },
        scales: {
          x: {
            ticks: { color: SLATE_MUTED, maxRotation: 45, minRotation: 0 },
            grid: { display: false }
          },
          y: {
            beginAtZero: true,
            ticks: { color: SLATE_MUTED, precision: 0 },
            grid: { color: "rgba(148, 163, 184, 0.2)" }
          }
        }
      })
    })
  }

  renderDoughnut(canvas, data) {
    if (!canvas || !data?.labels?.length) return null
    if ((data.values || []).every((v) => Number(v) === 0)) return null

    return new window.Chart(canvas, {
      type: "doughnut",
      data: {
        labels: data.labels,
        datasets: [{
          data: data.values,
          backgroundColor: data.labels.map((_, i) => PALETTE[i % PALETTE.length]),
          borderWidth: 0,
          hoverOffset: 4
        }]
      },
      options: this.baseOptions({
        cutout: "62%",
        plugins: {
          legend: {
            position: "bottom",
            labels: { color: SLATE_MUTED, boxWidth: 10, padding: 14 }
          }
        }
      })
    })
  }

  renderLine(canvas, data, label) {
    if (!canvas || !data?.labels?.length) return null

    return new window.Chart(canvas, {
      type: "line",
      data: {
        labels: data.labels,
        datasets: [{
          label,
          data: data.values,
          borderColor: TEAL,
          backgroundColor: "rgba(15, 118, 110, 0.12)",
          fill: true,
          tension: 0.35,
          pointRadius: 3,
          pointBackgroundColor: TEAL,
          borderWidth: 2
        }]
      },
      options: this.baseOptions({
        plugins: { legend: { display: false } },
        scales: {
          x: {
            ticks: { color: SLATE_MUTED, maxTicksLimit: 7 },
            grid: { display: false }
          },
          y: {
            beginAtZero: true,
            ticks: { color: SLATE_MUTED, precision: 0 },
            grid: { color: "rgba(148, 163, 184, 0.2)" }
          }
        }
      })
    })
  }

  baseOptions(extra = {}) {
    return {
      responsive: true,
      maintainAspectRatio: false,
      animation: { duration: 450 },
      ...extra
    }
  }

  destroyCharts() {
    ;(this.charts || []).forEach((chart) => chart.destroy())
    this.charts = []
  }
}
