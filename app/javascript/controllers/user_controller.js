import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="user"
export default class extends Controller {
  static targets = ["userMenu"];

  connect() {}

  toggleMenu() {
    const isActive = this.userMenuTarget.dataset.active === 'true';
    this.userMenuTarget.style.display = isActive ? "none" : "flex";
    this.userMenuTarget.dataset.active = !isActive;

    if (!isActive) {
      document.addEventListener('click', this.#handleOutsideClick.bind(this));
    } else {
      document.removeEventListener('click', this.#handleOutsideClick.bind(this));
    }
  }

  // Private

  #handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.#hideMenu();
    }
  }

  #hideMenu() {
    this.userMenuTarget.style.display = "none";
    this.userMenuTarget.dataset.active = false;
    document.removeEventListener('click', this.#handleOutsideClick.bind(this));
  }
}
