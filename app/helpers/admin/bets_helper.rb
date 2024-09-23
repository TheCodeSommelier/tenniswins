# frozen_string_literal: true

module Admin
  module BetsHelper
    def calculate_total_odds(bets)
      bets.map(&:eu_odds).reduce(1, :*)
    end
  end
end
