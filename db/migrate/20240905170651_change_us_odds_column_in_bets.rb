# frozen_string_literal: true

class ChangeUsOddsColumnInBets < ActiveRecord::Migration[7.1]
  def up
    change_column :bets, :us_odds, :integer
  end

  def down
    change_column :bets, :us_odds, :decimal
  end
end
