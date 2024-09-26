# frozen_string_literal: true

class UserBet < ApplicationRecord
  belongs_to :bet
  belongs_to :user
end
