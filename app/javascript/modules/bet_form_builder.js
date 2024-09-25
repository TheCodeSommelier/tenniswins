export default class BetFormBuilder {
  constructor(formUtils) {
    this.formUtils = formUtils;
    this.betCount = 1;
  }

  buildBetForm() {
    const submitButton = document.querySelector('input[type="submit"]');
    const betFormCont = this.createBetFormContainer();

    submitButton.insertAdjacentElement("beforebegin", betFormCont);

    this.createBetFields(betFormCont, this.betCount);
    betFormCont.appendChild(this.createOddsSection(this.betCount));

    this.createCalculateOddsButton(betFormCont);

    this.betCount++;
  }

  createBetFormContainer() {
    const container = document.createElement("div");
    container.classList.add("bet-form-cont", `bet-${this.betCount}`);
    return container;
  }

  createOddInputsContainer() {
    const container = document.createElement("div");
    container.classList.add("odd-cont");
    return container;
  }

  createBetFields(parent, betIndex) {
    const formFieldDiv = this.createFormFieldDiv();
    const autocompleteUl = this.formUtils.buildUl({
      classes: ["autocomplete-results", `bet-${this.betCount}-autocomplete`]
    });

    const betNameLabel = this.formUtils.buildLabel({
      for: `bet_${betIndex}_name`,
      classes: ["form-label"],
    });
    betNameLabel.innerText = `Bet ${betIndex} Name:`;

    const betNameInput = this.formUtils.buildInput({
      name: `bets[bet${betIndex}][name]`,
      id: `bet_${betIndex}_name`,
      type: "text",
      placeholder: "Federer vs. Muroň",
      data: { action: "keyup->bets#autocomplete" },
      required: true
    });

    formFieldDiv.appendChild(betNameLabel);
    formFieldDiv.appendChild(betNameInput);
    formFieldDiv.appendChild(autocompleteUl)
    parent.appendChild(formFieldDiv);
  }

  createOddsSection(betIndex) {
    const oddsFieldDivs = [this.createFormFieldDiv(), this.createFormFieldDiv(), this.createFormFieldDiv()];
    const oddInputsCont = this.createOddInputsContainer();

    const betOddsLabel = this.formUtils.buildLabel({
      for: `bet_${betIndex}_eu_odds`,
      classes: ["form-label"],
    });
    betOddsLabel.innerText = `Bet ${betIndex} EU odds:`;

    const betOddsInput = this.formUtils.buildInput({
      name: `bets[bet${betIndex}][eu_odds]`,
      id: `bet_${betIndex}_eu_odds`,
      type: "number",
      step: 0.01,
      placeholder: "e.g., 2.50",
      classes: ["odds-input"],
      required: true
    });

    oddInputsCont.appendChild(oddsFieldDivs[0])
    oddInputsCont.appendChild(oddsFieldDivs[1])
    oddInputsCont.appendChild(oddsFieldDivs[2])

    oddsFieldDivs[0].appendChild(betOddsLabel);
    oddsFieldDivs[0].appendChild(betOddsInput);

    const betUsOddsLabel = this.formUtils.buildLabel({
      for: `bet_${betIndex}_us_odds`,
      classes: ["form-label"],
    });
    betUsOddsLabel.innerText = `Bet ${betIndex} US Odds:`;

    const betUsOddsInput = this.formUtils.buildInput({
      name: `bets[bet${betIndex}][us_odds]`,
      id: `bet_${betIndex}_us_odds`,
      type: "number",
      step: 1,
      placeholder: "e.g., 150",
      classes: ["us-odds-input"],
      required: true
    });

    oddsFieldDivs[1].appendChild(betUsOddsLabel);
    oddsFieldDivs[1].appendChild(betUsOddsInput);

    const betPickLabel = this.formUtils.buildLabel({
      for: `bet_${betIndex}_pick`,
      classes: ["form-label"],
    });
    betPickLabel.innerText = `Bet ${betIndex} pick:`;

    const betPickInput = this.formUtils.buildInput({
      name: `bets[bet${betIndex}][pick]`,
      id: `bet_${betIndex}_us_odds`,
      type: "text",
      placeholder: "e.g. Muroň to win",
      classes: ["pick-input"],
      required: true
    });

    oddsFieldDivs[2].appendChild(betPickLabel);
    oddsFieldDivs[2].appendChild(betPickInput);

    return oddInputsCont;
  }

  createCalculateOddsButton(parent) {
    const calcOddsButton = this.formUtils.buildButton({
      type: "button",
      id: `calculate-odds-button-${this.betCount}`,
      classes: ["c-button--outline"],
      data: { action: "click->bets#calculateOdds" },
      text: "Calculate US odds",
    });

    parent.appendChild(calcOddsButton);
  }

  createFormFieldDiv() {
    const div = document.createElement("div");
    div.classList.add("field");
    return div;
  }
}
