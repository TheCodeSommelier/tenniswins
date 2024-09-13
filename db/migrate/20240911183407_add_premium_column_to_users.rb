class AddPremiumColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :premium, :boolean, default: false
  end
end
