class DropMatchesBetsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :matches_bets
  end

  def down
    create_table :matches_bets do |t|
      t.references :bet, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
