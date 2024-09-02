class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.string :name
      t.string :tournament

      t.timestamps
    end
  end
end
