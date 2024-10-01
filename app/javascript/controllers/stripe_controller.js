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

  async handleFormSubmission() {
    const form = document.querySelector(".c-checkout__payment-form");

    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      this.#showProcessingMessage();

      try {
        // Validate the payment element
        const { error: submitError } = await this.elements.submit();
        if (submitError) {
          throw submitError;
        }

        // Create a PaymentMethod from the payment element
        const { error: paymentMethodError, paymentMethod } =
          await this.stripe.createPaymentMethod({
            elements: this.elements,
          });

        if (paymentMethodError) {
          throw paymentMethodError;
        }

        // Update the payment method on your server and get an updated client secret
        const updatedPaymentIntent = await this.#updatePaymentMethod(
          paymentMethod.id
        );

        // Confirm the payment with the updated client secret
        const { error: confirmError, paymentIntent } =
          await this.stripe.confirmPayment({
            clientSecret: updatedPaymentIntent.client_secret,
            confirmParams: {
              payment_method: paymentMethod.id,
              return_url: `${this.baseURL}/stripe/success`,
            },
            redirect: "if_required",
          });

        if (confirmError) {
          throw confirmError;
        }

        if (paymentIntent.status === "succeeded") {
          if (this.isRecurring) {
            await this.#subscribeCustomer(paymentIntent.payment_method);
          }
          window.location.href = `${this.baseURL}/stripe/success`;
        }
      } catch (error) {
        const messageContainer = document.querySelector(
          ".c-checkout__error-messages"
        );
        messageContainer.textContent = error.message;
        console.log(error);

        this.#removeProcessingMessage();
      }
    });
  }

  // Private

  async #createPaymentElement() {
    const paymentData = await this.#fetchPaymentData();
    this.isRecurring = paymentData.recurring;
    this.clientSecret = paymentData.client_secret;

    if (!this.clientSecret) {
      console.error("Failed to fetch client secret.");
      return;
    }

    this.#createPaymentForm(this.clientSecret);
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
    this.elements = this.stripe.elements({
      clientSecret,
      appearance,
      paymentMethodCreation: "manual",
    });
    const paymentElement = this.elements.create("payment", options);
    paymentElement.mount(".c-checkout__payment-element");
  }

  async #subscribeCustomer(paymentMethodId) {
    const response = await fetch("/stripe/subscribe-customer", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        prod_id: this.prodId,
        payment_method_id: paymentMethodId,
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    const data = await response.json();
    window.location.href = `${this.baseURL}/stripe/success`;
  }

  async #updatePaymentMethod(paymentMethodId) {
    const response = await fetch("/stripe/update-payment-method", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({
        paymentMethodId: paymentMethodId,
        paymentIntentId: this.clientSecret.split("_secret_")[0],
        productId: this.prodId,
      }),
    });

    if (!response.ok) {
      throw new Error("Failed to update payment method");
    }

    return await response.json();
  }

  #showProcessingMessage() {
    const flashMessage = document.createElement("div");
    flashMessage.className = "c-flash--success";
    flashMessage.innerHTML = `
      <div class="c-flash__loader"></div>
      <p>Your payment is being processed</p>
    `;
    document.body.insertBefore(flashMessage, document.body.firstChild);
  }

  #removeProcessingMessage() {
    const flashMessage = document.querySelector(".c-flash--success");
    flashMessage.remove();
  }
}
