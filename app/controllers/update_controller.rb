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
      redirect_to update_path
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

  def new
    if IsItemBarcode.call(params[:old_barcode])
      @old_item = Item.where(barcode: params[:old_barcode]).take
    else
      flash[:error] = 'old barcode is not an item'
      redirect_to update_path
      return
    end

    if @old_item.blank?
      flash[:error] = "No item was found with barcode #{params[:old_barcode]}"
      redirect_to update_path
      return
    end

    if IsItemBarcode.call(params[:new_barcode])
      @new_item = Item.where(barcode: params[:new_barcode]).take
    else
      flash[:error] = 'new barcode is not an item'
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end

    if @new_item.blank?
      flash[:error] = "No item was found with barcode #{params[:new_barcode]}"
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end

    redirect_to show_new_update_path(old_id: @old_item.id, new_id: @new_item.id)
    return
  end

  def show_new
    @old_item = Item.find(params[:old_id])
    @new_item = Item.find(params[:new_id])
  end
end
