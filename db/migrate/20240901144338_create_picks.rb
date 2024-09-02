class CreatePicks < ActiveRecord::Migration[7.1]
  def change
    create_table :picks do |t|
      t.decimal :odds
      t.decimal :us_odds
      t.boolean :won

      t.timestamps
    end
  end
end
