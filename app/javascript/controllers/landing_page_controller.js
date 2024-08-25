import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="landing-page"
export default class extends Controller {
  static targets = ["stepDesc"];

  connect() {}

  changeStep(event) {
    const oldStep = document
      .getElementById("how-it-works")
      .querySelector(".active");
    const clickedStep = event.currentTarget;
    const stepNumber = clickedStep.id.split("-")[1];
    const newText = this.getStepDescription(stepNumber);
    oldStep.classList.remove("active");
    clickedStep.classList.add("active");

    this.fadeOutIn(newText);
  }

  fadeOutIn(newText) {
    const descElement = this.stepDescTarget;

    // Fade out
    descElement.classList.add("fade-out");

    // Wait for fade out to complete, then change text and fade in
    setTimeout(() => {
      descElement.textContent = newText;
      descElement.classList.remove("fade-out");
      descElement.classList.add("fade-in");

      // Remove the fade-in class after transition completes
      setTimeout(() => {
        descElement.classList.remove("fade-in");
      }, 300); // This should match your CSS transition duration
    }, 300); // This should match your CSS transition duration
  }

  getStepDescription(stepNumber) {
    // Replace with your actual step descriptions
    const descriptions = {
      1: "Sign up with a free account to explore our historical data and gain access to our community channels on Discord/Telegram. See how our picks have performed over time and evaluate the quality of our insights.",
      2: "Unlock daily tennis picks by upgrading to our paid service. For $99/month, you’ll receive expertly curated selections, designed for those who prioritize steady, reliable returns with around $50 per pick.",
      3: "Once you’re a paid member, our daily tennis picks will be delivered directly to your inbox every morning. You can also access them anytime in the members-only section of our site, ensuring you never miss an opportunity.'",
    };

    return descriptions[stepNumber] || "Description not available.";
  }
}
