class CreateParleys < ActiveRecord::Migration[7.1]
  def change
    create_table :parleys do |t|
      t.decimal :odds
      t.decimal :us_odds
      t.decimal :total_odds
      t.boolean :won

      t.timestamps
    end
  end
end
