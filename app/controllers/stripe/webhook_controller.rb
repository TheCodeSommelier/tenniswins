# frozen_string_literal: true

module Stripe
  class WebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def handle_webhook
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV.fetch('STRIPE_WH_TEST_KEY')

      event = nil
      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        render status: 400, plain: 'Invalid payload or signature verification failed'
        return
      end

      case event['type']
      when 'payment_intent.succeeded'
        payment_intent = event.data.object
        customer = User.find_by(stripe_customer_id: payment_intent.customer)
        handle_successful_payment_intent(payment_intent, customer)
      when 'customer.subscription.created'
        payment_intent = event.data.object
        customer = User.find_by(stripe_customer_id: payment_intent.customer)
        customer.update(premium: true)
        UsersMailer.welcome_new_user(customer).deliver_later
      when 'customer.subscription.deleted'
      else
        Rails.logger.warn "Unhandled event type: #{event['type']}"
      end

      head :ok
    end

    private

    def handle_successful_payment_intent(payment_intent, customer)
      product_id = payment_intent.metadata['product_id']
      price_id = payment_intent.metadata['price_id']
      product = Stripe::Product.retrieve(product_id)

      if payment_intent.metadata['recurring'] == 'false'
        credits = product.metadata['credits'].to_i
        credits += customer.credits || 0
        customer.update(credits:)
      end

      Rails.logger.info "Handled payment intent for product_id: #{product.id}, price_id: #{price_id}"
    end
  end
end
