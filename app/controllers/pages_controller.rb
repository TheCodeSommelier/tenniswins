# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @number_won_bets = Bet.number_won_bets

    single_bet_money_made = Bet.where(won: true, parlay_group: nil).sum('100 * (odds - 1)')

    parlay_money_made = Bet.where(won: true).where.not(parlay_group: nil)
                           .group(:parlay_group)
                           .pluck(:parlay_group)
                           .sum do |group|
                             total_odds = Bet.where(parlay_group: group).pluck(:odds).reduce(1) do |product, odds|
                               product * odds
                             end
                             100 * (total_odds - 1)
                           end

    @money_made = (single_bet_money_made + parlay_money_made).to_i
  end

  def membership; end

  def contact; end

  def cookie_consent; end
end
