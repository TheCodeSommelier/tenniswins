# frozen_string_literal: true

class AddParleyGroupToBets < ActiveRecord::Migration[7.1]
  def change
    add_column :bets, :parlay_group, :string
  end
end
