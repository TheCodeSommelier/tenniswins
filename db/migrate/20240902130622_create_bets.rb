# frozen_string_literal: true

class CreateBets < ActiveRecord::Migration[7.1]
  def change
    create_table :bets do |t|
      t.decimal :odds
      t.decimal :us_odds
      t.decimal :total_odds
      t.boolean :won

      t.timestamps
    end
  end
end
