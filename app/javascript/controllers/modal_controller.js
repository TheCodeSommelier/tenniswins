import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    this.modal = this.element.querySelector("#modal");
  }

  showModal() {
    this.modal.style.display = "flex";
  }

  hideModal() {
    this.element.style.display = "none";
  }
}
