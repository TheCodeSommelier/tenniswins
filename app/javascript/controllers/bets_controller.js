import { Controller } from "@hotwired/stimulus";
import FormUtils from "modules/form_utils";
import BetFormBuilder from "modules/bet_form_builder";

// Connects to data-controller="bets"
export default class extends Controller {
  static targets = ["results", "decimalInput", "result"];

  connect() {
    if (!this.element.dataset.controller.includes("edit-bets")) {
      this.formUtils = new FormUtils
      this.betFormBuilder = new BetFormBuilder(this.formUtils)
      this.betFormBuilder.buildBetForm()
    }
  }

  addBetForm() {
    this.betFormBuilder.buildBetForm()
  }

  autocomplete(event) {
    const betNameInput = event.target;
    const query = betNameInput.value;

    fetch(`matches_autocomplete?query=${query}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({ query: query }),
    })
      .then((response) => response.json())
      .then((data) => {
        this.#displayResults(data, betNameInput);
      });
  }

  calculateOdds(event) {
    const button = event.target;
    const oddsInput = button.previousElementSibling.querySelector(".odds-input");
    const usOddsInput = button.previousElementSibling.querySelector(".us-odds-input");

    const decimalOdds = parseFloat(oddsInput.value);

    if (isNaN(decimalOdds) || oddsInput.value === "") {
      usOddsInput.value = "";
      return;
    }

    let americanOdds = 0

    if (decimalOdds >= 1.01 && decimalOdds <= 1.99) {
      americanOdds = -100 / (decimalOdds - 1);
    } else if (decimalOdds >= 2.00) {
      americanOdds = (decimalOdds - 1) * 100;
    }

    usOddsInput.value = Math.round(americanOdds);
  }

  // Private

  #displayResults(matches, betNameInput) {
    this.#clearResults(betNameInput);

    matches.forEach((match) => {
      const resultItem = document.createElement("li");
      resultItem.textContent = match;

      resultItem.addEventListener("click", () => {
        this.#selectMatch(match, betNameInput);
      });

      betNameInput.nextElementSibling.appendChild(resultItem);
    });
  }

  #selectMatch(match, betNameInput) {
    betNameInput.value = match;
    this.#clearResults(betNameInput);
  }

  #clearResults(betNameInput) {
    betNameInput.nextElementSibling.innerHTML = "";
  }
}
