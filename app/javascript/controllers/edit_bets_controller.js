import { Controller } from "@hotwired/stimulus";
import FormUtils from "modules/form_utils";
import BetFormBuilder from "modules/bet_form_builder";

// Connects to data-controller="edit-bets"
export default class extends Controller {
  async connect() {
    this.formUtils = new FormUtils();
    this.betFormBuilder = new BetFormBuilder(this.formUtils);
    this.#fetchBetData();
  }

  #fetchBetData() {
    fetch(`edit-bet-data`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    })
      .then((response) => response.json())
      .then((data) => {
        this.#buildForms(data);
        this.#fillDataInputs(data);
      });
  }

  #buildForms(data) {
    for (let i = 0; i < data.matches.length; i++) {
      this.betFormBuilder.buildBetForm();
    }
    this.#buildHiddenIdInputs(data)
  }

  #fillDataInputs(data) {
    const matchNameInputs = Array.from(
      document.querySelectorAll('input[type="text"]')
    );
    const oddsInputs = Array.from(document.querySelectorAll(".odds-input"));
    const usOddsInputs = Array.from(
      document.querySelectorAll(".us-odds-input")
    );

    for (let i = 0; i < data.matches.length; i++) {
      matchNameInputs[i].value = data.matches[i];
      oddsInputs[i].value = parseFloat(data.bets[i].odds);
      usOddsInputs[i].value = parseInt(data.bets[i].us_odds, 10);
    }
  }

  #buildHiddenIdInputs(data) {
    for (let i = 0; i < data.bets.length; i++) {
      let hiddenIdInput = this.formUtils.buildInput({
        name: `bets[bet${i + 1}][betId]`,
        value: data.bets[i].id,
        type: "hidden",
      });
      const submitButton = document.querySelector('input[type="submit"]');
      submitButton.insertAdjacentElement("beforebegin", hiddenIdInput);
    }
  }
}
