import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="user"
export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("is-active");
  }

  // Close the dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("is-active");
    }
  }

  connect() {
    document.addEventListener("click", this.clickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside.bind(this));
  }
}
