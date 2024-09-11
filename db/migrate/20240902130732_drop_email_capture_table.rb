# frozen_string_literal: true

class DropEmailCaptureTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :email_captures
  end

  def down
    create_table :email_captures do |t|
      t.string :email

      t.timestamps
    end
  end
end
