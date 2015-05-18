class BinsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bins = Bin.includes(:items).where.not(items: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove
    @item = Item.find(params[:item_id])
    bin_id = @item.bin.id

    @item.bin = nil
    @item.save!

    redirect_to show_bin_path(:id => bin_id)
  end

end
