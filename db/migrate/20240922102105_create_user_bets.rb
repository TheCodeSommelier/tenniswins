# frozen_string_literal: true

class CreateUserBets < ActiveRecord::Migration[7.1]
  def change
    create_table :user_bets do |t|
      t.references :bet, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
