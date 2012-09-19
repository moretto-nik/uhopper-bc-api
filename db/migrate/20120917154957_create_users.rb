class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id_cart
      t.integer :id_user, :default => 0

      t.timestamps
    end
    add_index :users, :id_cart, :unique => true
  end
end
