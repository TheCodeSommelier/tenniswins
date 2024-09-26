# frozen_string_literal: true

module Stripe
  class WebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def handle_webhook
      event = verify_webhook
      return if event.nil?

      process_event(event)
      head :ok
    end

    private

    def verify_webhook
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV.fetch('STRIPE_WH_TEST_KEY')

      Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error "Invalid payload or signature: #{e.message}"
      render status: 400, plain: 'Invalid payload or signature verification failed'
      nil
    end

    def process_event(event)
      case event['type']
      when 'payment_intent.succeeded' then handle_payment_intent_succeeded(event.data.object)
      when 'customer.subscription.created' then handle_subscription_created(event.data.object)
      when 'customer.subscription.deleted' then handle_subscription_deleted(event.data.object)
      when 'invoice.paid' then handle_invoice_paid(event.data.object)
      else
        Rails.logger.warn "Unhandled event type: #{event['type']}"
      end
    end

    def handle_payment_intent_succeeded(payment_intent)
      customer = find_customer(payment_intent.customer)
      log_event('payment_intent.succeeded', payment_intent.id, customer&.id)

      assign_credits(payment_intent, customer) if payment_intent.metadata['recurring'] == 'false'
    end

    def handle_subscription_created(subscription_data)
      customer = find_customer(subscription_data.customer)
      customer.update(premium: true)
      UsersMailer.welcome_new_user(customer).deliver_later
    end

    def handle_subscription_deleted(subscription_data)
      customer = find_customer(subscription_data.customer)
      UsersMailer.send_goodbye(customer).deliver_later
    end

    def handle_invoice_paid(invoice_data)
      customer = find_customer(invoice_data.customer)
      UsersMailer.send_receipt(customer, invoice_data.id).deliver_later
    end

    def find_customer(stripe_customer_id)
      User.find_by(stripe_customer_id:)
    end

    def log_event(event_type, event_id, customer_id)
      Rails.logger.info "🔥 Received #{event_type} event: #{event_id} for customer: #{customer_id}"
    end

    def assign_credits(payment_intent, customer)
      product_id = payment_intent.metadata['product_id']
      price_id = payment_intent.metadata['price_id']
      product = Stripe::Product.retrieve(product_id)
      credits = product.metadata['credits'].to_i
      credits += customer.credits
      customer.update(credits:)
      Rails.logger.info "Handled payment intent for product_id: #{product.id}, price_id: #{price_id}"
    end
  end
end
