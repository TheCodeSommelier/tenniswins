# frozen_string_literal: true

class AddCreditsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :credits, :integer
  end
end
