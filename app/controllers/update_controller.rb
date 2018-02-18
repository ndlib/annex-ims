class UpdateController < ApplicationController
  before_action :require_admin

  def index
    @old_item = Item.new
    @new_item = Item.new
  end

  def old
    if IsItemBarcode.call(params[:old_barcode])
      @old_item = Item.where(barcode: params[:old_barcode]).take
    else
      flash[:error] = 'barcode is not an item'
      redirect_tp update_path
      return
    end

    if @old_item.blank?
      flash[:error] = "No item was found with barcode #{params[:old_barcode]}"
      redirect_to update_path
      return
    end

    redirect_to show_old_update_path(id: @old_item.id)
    return
  end

  def show_old
    @old_item = Item.find(params[:id])
    @new_item = Item.new
  end
end
