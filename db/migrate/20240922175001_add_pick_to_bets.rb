class AddPickToBets < ActiveRecord::Migration[7.1]
  def change
    add_column :bets, :pick, :string
  end
end
