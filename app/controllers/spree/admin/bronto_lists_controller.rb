class Spree::Admin::BrontoListsController < Spree::Admin::ResourceController
  before_action :find_stores, only: [:edit, :new]

  def get_lists
    @lists = []
    @list_id = params[:list_id] if params.key? :list_id
    @store_id = params[:store_id] if params.key? :store_id
    @site= Spree::Store.find(@store_id)
    bronto=Bronto.new(Spree::BrontoConfiguration.account[@site.code]['token'])
    et_lists=bronto.read_lists
    #et_list = ET::List.new(Spree::Config.get(:exact_target_user), Spree::Config.get(:exact_target_password))
    et_lists.each do |etl|
      #list = et_list.retrieve_by_id etl[:id]
      @lists << ["#{etl[:name]}", etl[:id]]
    end
    render :partial => "get_lists", :layout => false
  end

  private

  def find_stores
    @stores=Spree::Store.all
  end
end
