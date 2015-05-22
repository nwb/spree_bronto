module Spree
 Store.class_eval do

    has_many :bronto_lists, class_name: "Spree::BrontoList"

  end
end