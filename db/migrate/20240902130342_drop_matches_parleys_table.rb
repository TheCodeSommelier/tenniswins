class DropMatchesParleysTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :matches_parleys
  end

  def down
    create_table :matches_parleys do |t|
      t.references :parley, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
