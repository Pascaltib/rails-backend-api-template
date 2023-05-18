# frozen_string_literal: true

class AddPhoneNumberToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number, :string, null: false, default: ''
    add_index :users, :phone_number, unique: true, where: "phone_number != ''"
  end
end
