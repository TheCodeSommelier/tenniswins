# frozen_string_literal: true

module Stripe
  class CheckoutController < ApplicationController
    def new; end

    def send_client_secret
      product = Stripe::Product.retrieve(params[:prod_id])
      price = Stripe::Price.retrieve(product.default_price)
      amount = price.unit_amount.to_f / 100
      client_secret = price.recurring ? create_setup_intent : create_payment_intent(price)
      recurring = price.recurring ? true : false

      render json: { client_secret:, requires_action: false, amount:, recurring: }
    end

    private

    def create_setup_intent
      setup_intent = Stripe::SetupIntent.create({
                                                  payment_method_types: ['card'],
                                                  usage: 'off_session'
                                                })

      setup_intent.client_secret
    end

    def create_payment_intent(price)
      payment_intent = Stripe::PaymentIntent.create({
                                                      amount: price.unit_amount,
                                                      currency: price.currency,
                                                      payment_method_types: ['card']
                                                    })
      payment_intent.client_secret
    end
  end
end
