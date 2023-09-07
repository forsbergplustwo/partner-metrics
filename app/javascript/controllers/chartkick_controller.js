import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chart", "data", "options"]

  connect() {
    this.createChart()
  }

  createChart() {
    if (document.documentElement.hasAttribute("data-turbolinks-preview")) return
    if (document.documentElement.hasAttribute("data-turbo-preview")) return

    if ("Chartkick" in window && this.hasChartTarget && this.hasDataTarget && this.hasOptionsTarget) {
      const chart = this.chartTarget.id
      const data = JSON.parse(this.dataTarget.textContent)
      const configuration = JSON.parse(this.optionsTarget.textContent)

      new Chartkick["AreaChart"](this.chartTarget, data, configuration)
    }
  }
}
