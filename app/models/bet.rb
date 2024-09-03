class Bet < ApplicationRecord
  belings_to :match

  def part_of_parlay?
    parlay_group.present?
  end
end
