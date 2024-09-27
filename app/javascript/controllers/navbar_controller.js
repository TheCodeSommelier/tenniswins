import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.lastScrollTop = 0;
    this.ticking = false;
    window.addEventListener("scroll", () => this.handleScroll());
  }

  toggleMenu() {
    this.menuTarget.classList.toggle("is-active");
  }

  handleScroll() {
    const st = window.scrollY || document.documentElement.scrollTop;

    if (!this.ticking) {
      window.requestAnimationFrame(() => {
        if (st > this.lastScrollTop && st > 60) {
          // Scrolling down
          this.element.classList.add("navbar--hidden");
        } else {
          // Scrolling up
          this.element.classList.remove("navbar--hidden");
        }
        this.lastScrollTop = st <= 0 ? 0 : st;
        this.ticking = false;
      });

      this.ticking = true;
    }
  }
}
