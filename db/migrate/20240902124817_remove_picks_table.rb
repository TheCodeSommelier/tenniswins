class RemovePicksTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :picks
  end

  def down
    create_table :picks do |t|
      t.string :pick_type
      t.decimal :odds, precision: 5, scale: 2
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
