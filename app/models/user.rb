# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_bets
  has_many :bets, through: :user_bets

  after_create :create_stripe_customer

  validates :first_name, :last_name, presence: true

  private

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email:
    )
    update(stripe_customer_id: customer.id)
  end
end
