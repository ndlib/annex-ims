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

    begin
      @test_item = Item.where(barcode: params[:new_barcode]).take
      unless @test_item.blank?
        flash[:error] =  "Barcode #{@test_item.barcode} alreadys exists as a different item in the Annex."
        redirect_to show_existing_update_path(old_id: @old_item.id, exist_id: @test_item.id)
        return
      end

      @new_item = GetItemFromMetadata.call(barcode: params[:new_barcode], user_id: current_user.id)
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end

    if @new_item.blank?
      flash[:error] = "No item was found with barcode #{params[:new_barcode]}"
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end

    redirect_to show_new_update_path(old_id: @old_item.id,
      new_barcode: @new_item.barcode)
    return
  end

  def show_new
    @old_item = Item.find(params[:old_id])
    begin
      @new_item = GetItemFromMetadata.call(barcode: params[:new_barcode], user_id: current_user.id)
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end
  end

  def show_existing
    @old_item = Item.find(params[:old_id])
    @new_item = Item.find(params[:exist_id])
  end

  def merge
    old_item = Item.find(params[:old_id])
    begin
      MergeNewMetadataToOldItem.call(old_id: params[:old_id],
        new_barcode: params[:new_barcode], user_id: current_user.id)
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to show_old_update_path(id: @old_item.id)
      return
    end

    flash[:notice] = "Barcode #{old_item.barcode} was successfully updated to Barcode #{params[:new_barcode]}"

    redirect_to update_path
    return
  end
end
