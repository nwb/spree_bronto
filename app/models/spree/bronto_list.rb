module Spree
  class BrontoList < ActiveRecord::Base
    has_and_belongs_to_many :users, class_name: "Spree::User", join_table: :spree_bronto_lists_users
    belongs_to :store,  class_name: "Spree::Store"
    validates_presence_of :title
    validates_uniqueness_of :list_id, :message => I18n.t("bronto.validate_unique")
    #validates_numericality_of :list_id

    scope :by_store, lambda { |store| joins(:stores).where("spree_bronto_lists.store_id = ?", store) }

    def validate
      if self.new_record?
        errors.add_to_base I18n.translate("bronto.only_list_can_subscribe_all") if self.subscribe_all_new_users && BrontoList.exists?(["subscribe_all_new_users = ?" , true])
      else
        errors.add_to_base I18n.translate("bronto.only_list_can_subscribe_all") if self.subscribe_all_new_users && BrontoList.exists?(["subscribe_all_new_users = ? AND id <> ?" , true, self.id])
      end
    end
  end

end
