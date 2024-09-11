# frozen_string_literal: true

class CreateMatchesParleys < ActiveRecord::Migration[7.1]
  def change
    create_table :matches_parleys do |t|
      t.references :parley, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
