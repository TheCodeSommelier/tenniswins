# frozen_string_literal: true

class Bet < ApplicationRecord
  belongs_to :match
  has_many :user_bets, dependent: :destroy
  has_many :users, through: :user_bets

  validates :eu_odds, :us_odds, :pick, presence: true

  def part_of_parlay?
    parlay_group.present?
  end

  def self.number_won_bets
    standalone_won_bets = Bet.where(won: true, parlay_group: nil).count
    standalone_won_bets + parlays_won
  end

  private_class_method def self.parlays_won
    Bet.where(won: true).where.not(parlay_group: nil).distinct.count(:parlay_group)
  end
end
