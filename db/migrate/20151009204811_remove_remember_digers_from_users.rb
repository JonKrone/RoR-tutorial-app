class RemoveRememberDigersFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :remember_digers, :string
  end
end
