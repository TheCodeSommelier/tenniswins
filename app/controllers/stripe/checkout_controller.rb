# frozen_string_literal: true

module Stripe
  class CheckoutController < ApplicationController
    def new; end

    def send_client_secret
      product = Stripe::Product.retrieve(params[:prod_id])
      price = Stripe::Price.retrieve(product.default_price)
      recurring = (price.recurring&.interval == 'month') || false
      amount = price.unit_amount.to_f / 100
      client_secret = create_payment_intent(price, product, recurring)

      render json: { client_secret:, requires_action: false, amount:, recurring: }
    end

    def create_subscription
      stripe_cus_id = current_user.stripe_customer_id
      payment_method_id = params[:payment_method_id]
      p "🔥 stripe_cus_id => #{stripe_cus_id} --- payment_method_id => #{payment_method_id}"
      product = Stripe::Product.retrieve(params[:prod_id])
      price = Stripe::Price.retrieve(product.default_price)

      attach_payment_method(payment_method_id, stripe_cus_id)

      set_default_payment_method(payment_method_id, stripe_cus_id)

      Stripe::Subscription.create({
                                    customer: stripe_cus_id,
                                    items: [{ price: price.id }],
                                    currency: 'usd',
                                    expand: ['latest_invoice.payment_intent'],
                                  })
      head :ok
    rescue Stripe::StripeError => e
      Rails.logger.error "🛑 Stripe error while creating subscription: #{e.message}"
    end

    def success; end

    private

    def attach_payment_method(payment_method_id, stripe_cus_id)
      Stripe::PaymentMethod.attach(payment_method_id, { customer: stripe_cus_id })
    rescue Stripe::StripeError => e
      Rails.logger.error "🛑 Stripe error while attaching payment method: #{e.message}"
    end

    def set_default_payment_method(payment_method_id, stripe_cus_id)
      Stripe::Customer.update(
        stripe_cus_id, {
          invoice_settings: { default_payment_method: payment_method_id }
        }
      )
    end

    def create_payment_intent(price, product, recurring)
      payment_intent = Stripe::PaymentIntent.create({
                                                      customer: current_user.stripe_customer_id,
                                                      amount: price.unit_amount,
                                                      currency: price.currency,
                                                      payment_method_types: ['card'],
                                                      metadata: { product_id: product.id, price_id: price.id,
                                                                  recurring: },
                                                      setup_future_usage: recurring ? 'off_session' : nil
                                                    })
      payment_intent.client_secret
    end
  end
end
