class SpreeBrontoListsUsers < ActiveRecord::Migration
  def self.up
    create_table :spree_bronto_lists_users, :id => false do |t|
      t.references :user
      t.references :bronto_list
      t.timestamps
    end
  end

  def self.down
  end
end