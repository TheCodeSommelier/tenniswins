import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cookies"
export default class extends Controller {
  static targets = [ 'marketingConsent', 'anyliticsConsent', 'cookieBanner' ];

  connect() {
    if (!this.#isCookieConsentSet('marketing') || !this.#isCookieConsentSet('analytics')) {
      this.#showBanner();
      this.#applyCookies('marketing')
      this.#applyCookies('analytics')
    }
  }

  acceptAllCookies() {
    this.#setConsent('marketing', 'granted', 365);
    this.#setConsent('analytics', 'granted', 365);
    this.#setConsent('necessary', 'granted', 365);
    this.#hideBanner()
    location.reload();
  }

  acceptPickedCookies() {
    const allowedAnalytics = this.anyliticsConsentTarget.checked ? 'granted' : 'denied';
    const allowedMarketing = this.marketingConsentTarget.checked ? 'granted' : 'denied';

    if (allowedMarketing === 'denied' && allowedAnalytics === 'denied') {
      this.denyAllCookies();
      return;
    }

    this.#setConsent('marketing', allowedAnalytics, 365);
    this.#setConsent('analytics', allowedMarketing, 365);
    this.#setConsent('necessary', 'granted', 365);
    this.#hideBanner()
    location.reload();
  }

  denyAllCookies() {
    this.#setConsent('marketing', 'denied', 1);
    this.#setConsent('analytics', 'denied', 1);
    this.#setConsent('necessary', 'granted', 1);
    this.#hideBanner()
    location.reload();
  }

  // Private

  #setConsent(type, value, days) {
    this.#setCookie(`${type}_cookie_consent`, value, days);
    if (type === 'marketing') {
      gtag('consent', 'update', {
        'ad_storage': value,
        'ad_user_data': value,
        'ad_personalization': value,
      });
    }

    if (type === 'analytics') {
      gtag('consent', 'update', {
        'analytics_storage': value
      });
    }
  }

  #applyCookies(type) {
    const cookieValue = this.#getCookieValue(`${type}_cookie_consent`);

    if (!cookieValue) return; // Guard clause no cookie no game

    if (type === 'marketing') {
      gtag('consent', 'update', {
        'ad_storage': cookieValue,
        'ad_user_data': cookieValue,
        'ad_personalization': cookieValue,
      });
    } else if (type === 'analytics') {
      gtag('consent', 'update', {
        'analytics_storage': cookieValue
      });
    }
  }

  #getCookieValue(name) {
    const nameEquals = `${name}=`;
    const cookieArray = document.cookie.split(';');

    for (let i = 0; i < cookieArray.length; i++) {
      let cookie = cookieArray[i].trim();
      if (cookie.indexOf(nameEquals) === 0) {
        return cookie.substring(nameEquals.length, cookie.length);
      }
    }
    return null;
  }

  #isCookieConsentSet(type) {
    return this.#getCookieValue(`${type}_cookie_consent`) !== null;
  }

  #showBanner() {
    if (this.hasCookieBannerTarget) {
      this.cookieBannerTarget.style.display = 'block';
    }
  }

  #hideBanner() {
    if (this.hasCookieBannerTarget) {
      this.cookieBannerTarget.style.display = 'none';
    }
  }

  #setCookie(name, value, days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    const expires = "expires=" + date.toUTCString();
    document.cookie = name + "=" + value + ";" + expires + ";path=/";
  }
}
