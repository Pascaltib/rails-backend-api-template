# frozen_string_literal: true

class AddAuthMethodToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth_method, :integer
  end
end
