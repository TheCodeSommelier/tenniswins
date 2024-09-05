module Admin::BetsHelper
  def calculate_total_odds(bets)
    decimal_odds_product = bets.map(&:odds).reduce(1, :*)
    decimal_odds_product
  end
end
