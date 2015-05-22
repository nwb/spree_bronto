class CreateSpreeBrontoLists < ActiveRecord::Migration
  def self.up
    create_table :spree_bronto_lists do |t|
      t.string :list_id
      t.string :title
      t.boolean :subscribe_all_new_users, :default => false
      t.boolean :visible, :default => true
      t.integer :store_id
      t.timestamps
    end
  end

  def self.down
    drop_table :spree_bronto_lists
  end
end
