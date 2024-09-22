class AddDefaultToCredits < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :credits, 0
  end
end
