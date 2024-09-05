class Bet < ApplicationRecord
  belongs_to :match

  validates :odds, :us_odds, presence: true

  def part_of_parlay?
    parlay_group.present?
  end
end
