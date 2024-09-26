# frozen_string_literal: true

class ChangeOddsToEuOddsInBets < ActiveRecord::Migration[7.1]
  def change
    rename_column :bets, :odds, :eu_odds
  end
end
