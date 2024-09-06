class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @number_won_bets = Bet.where(won: true).count

    single_bet_money_made = Bet.where(won: true, parlay_group: nil).sum('100 * (odds - 1)')

    parlay_money_made = Bet.where(won: true).where.not(parlay_group: nil)
                           .group(:parlay_group)
                           .sum('100 * (odds - 1)')

    total_parlay_money = parlay_money_made.values.sum

    @money_made = (single_bet_money_made + total_parlay_money).to_i
  end

  def membership; end

  def contact; end

  def cookie_consent; end
end
