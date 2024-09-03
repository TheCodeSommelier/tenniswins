class AddMatchReferenceToBets < ActiveRecord::Migration[7.1]
  def change
    add_reference :bets, :match, null: false, foreign_key: true
  end
end
