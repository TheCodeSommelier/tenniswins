# frozen_string_literal: true

if Rails.env.production?
  # Use live keys in production
  Stripe.api_key = ENV.fetch('STRIPE_SECRET_LIVE_KEY')
  Rails.application.config.x.stripe.publishable_key = ENV.fetch('STRIPE_PUBLIC_LIVE_KEY')
else
  # Use test keys in development and other environments
  Stripe.api_key = ENV.fetch('STRIPE_SECRET_TEST_KEY')
  Rails.application.config.x.stripe.publishable_key = ENV.fetch('STRIPE_PUBLIC_TEST_KEY')
end
