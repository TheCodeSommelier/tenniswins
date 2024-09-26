# frozen_string_literal: true

class AddEmailSubToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email_sub, :boolean, default: true
  end
end
