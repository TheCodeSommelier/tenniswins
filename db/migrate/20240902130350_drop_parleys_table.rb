class DropParleysTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :parleys
  end
end
