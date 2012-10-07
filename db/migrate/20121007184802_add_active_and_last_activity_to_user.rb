class AddActiveAndLastActivityToUser < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :default => false
    add_column :users, :last_activity, :string
  end
end
