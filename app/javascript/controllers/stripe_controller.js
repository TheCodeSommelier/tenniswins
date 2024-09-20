import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="stripe"
export default class extends Controller {
  static targets = ["priceSpan", "monthlySpan"];
  async connect() {
    const publicKey = this.element.dataset.publicKey;
    this.stripe = Stripe(publicKey);
    this.#fetchClientSecret();
  }

  // Private

  #fetchClientSecret() {
    const prodIdArr = window.location.search.split("=");
    const prodId = prodIdArr[prodIdArr.indexOf("?prod_id") + 1];
    fetch("get-client-secret", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({ prod_id: prodId }),
    })
      .then((response) => response.json())
      .then((data) => {
        this.#createThePaymentElement(data.client_secret);
        this.priceSpanTarget.innerText = `$${data.amount}`;
        this.monthlySpanTarget.innerText = data.recurring
          ? " / monthly"
          : " / one time fee";
      });
  }

  #createThePaymentElement(clientSecret) {
    const appearance = {
      theme: "night",
      variables: {
        colorPrimary: "#C1E021",
        colorDanger: "#df1b41",
        fontFamily: "Montserrat, sans-serif",
        borderRadius: "8px",
      },
    };
    const options = {
      business: {
        name: "Tenniswins",
      },
    };
    const elements = this.stripe.elements({ clientSecret, appearance });
    const paymentElement = elements.create("payment", options);
    paymentElement.mount("#payment-element");
  }
}
