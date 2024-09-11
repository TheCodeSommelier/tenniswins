# frozen_string_literal: true

class RemoveTotalOddsColumnFromBets < ActiveRecord::Migration[7.1]
  def up
    remove_column :bets, :total_odds
  end

  def down
    add_column :bets, :total_odds, :decimal, precision: 10, scale: 2
  end
end
