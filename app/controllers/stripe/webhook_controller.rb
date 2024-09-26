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
        Rails.logger.info "🔥 Received payment_intent.succeeded event: #{event['id']} for customer: #{customer&.id}"
        assign_credits(payment_intent, customer) if payment_intent.metadata['recurring'] == 'false'
      when 'customer.subscription.created'
        subscription_data = event.data.object
        customer = User.find_by(stripe_customer_id: subscription_data.customer)
        customer.update(premium: true)
        UsersMailer.welcome_new_user(customer).deliver_later
      when 'customer.subscription.deleted'
        subscription_data = event.data.object
        customer = User.find_by(stripe_customer_id: subscription_data.customer)
        UsersMailer.send_goodbye(customer)
      when 'invoice.paid'
        invoice_data = event.data.object
        customer = User.find_by(stripe_customer_id: invoice_data.customer)
        UsersMailer.send_reciept(customer, invoice_data.id).deliver_later
      else
        Rails.logger.warn "Unhandled event type: #{event['type']}"
      end

      head :ok
    end

    private

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
