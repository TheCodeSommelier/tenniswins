import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="stripe"
export default class extends Controller {
  static targets = ["priceSpan", "monthlySpan"];

  async connect() {
    const publicKey = this.element.dataset.publicKey;
    this.baseURL = `${window.location.protocol}//${window.location.host}`;
    if (!window.Stripe) {
      console.error("Stripe.js library is not loaded.");
      return;
    }

    const params = new URLSearchParams(window.location.search);
    this.prodId = params.get("prod_id");

    this.stripe = Stripe(publicKey);
    this.#createPaymentElement();
  }

  async handleFormSubmission(e) {
    const form = document.getElementById("payment-form");

    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      const error = await this.stripe
        .confirmPayment({
          elements: this.elements,
          confirmParams: {},
          redirect: 'if_required'
        })
        .then((result) => {
          if (result.error) {
            const messageContainer = document.querySelector("#error-message");
            messageContainer.textContent = result.error.message;
          } else {
            if (this.isRecurring) {
              this.#subscribeCustomer(result.paymentIntent.payment_method);
            }
            window.location.href = `${this.baseURL}/stripe/success`;
          }
        });

      if (error) {
        // This point will only be reached if there is an immediate error when
        // confirming the payment. Show error to your customer (for example, payment
        // details incomplete)
        const messageContainer = document.querySelector("#error-message");
        messageContainer.textContent = error.message;
        return;
      }
    });
  }

  // Private

  async #createPaymentElement(elements) {
    const paymentData = await this.#fetchPaymentData();
    this.isRecurring = paymentData.recurring;

    if (!paymentData.client_secret) {
      console.error("Failed to fetch client secret.");
      return;
    }

    this.#createPaymentForm(paymentData.client_secret);
    this.priceSpanTarget.innerText = `$${paymentData.amount}`;
    this.monthlySpanTarget.innerText = paymentData.recurring
      ? " / monthly"
      : " / one time fee";
  }

  async #fetchPaymentData() {
    const response = await fetch("get-client-secret", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({ prod_id: this.prodId }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  }

  #createPaymentForm(clientSecret) {
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
    this.elements = this.stripe.elements({ clientSecret, appearance });
    const paymentElement = this.elements.create("payment", options);
    paymentElement.mount("#payment-element");
    this.paymentElement = paymentElement;
  }

  async #subscribeCustomer(paymentMethodId) {
    try {
      const response = await fetch("/stripe/subscribe-customer", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({ prod_id: this.prodId, payment_method_id: paymentMethodId }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      const data = await response.json();
      window.location.href = `${this.baseURL}/stripe/success`;
    } catch (error) {
      console.error("Subscription error:", error);
    }
  }
}
