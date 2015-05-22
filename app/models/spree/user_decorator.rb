module Spree
  User.class_eval do

    has_and_belongs_to_many :bronto_lists, class_name: "Spree::BrontoList", join_table: :spree_bronto_lists_users

    accepts_nested_attributes_for :bronto_lists

  end
end