import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    this.eventHandler = this.show.bind(this);
    document.addEventListener("turbo:before-fetch-request", this.eventHandler);
  }

  disconnect() {
    document.removeEventListener(
      "turbo:before-fetch-request",
      this.eventHandler
    );
  }

  show() {
    this.overlayTargets.forEach((overlay) =>
      overlay.classList.toggle("hidden")
    );
  }
}
