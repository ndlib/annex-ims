class ShelvesController < ApplicationController
  def index
    @shelf = Shelf.new
  end

  def scan
    begin
      @shelf = GetShelfFromBarcode.call(params[:shelf][:barcode])
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to shelves_path
      return
    end
    redirect_to show_shelf_path(id: @shelf.id)
  end

  def show
    @shelf = Shelf.find(params[:id])
  end

  def shelf_detail
    @shelf = Shelf.where(barcode: params[:barcode]).take
    if @shelf
      @trays = @shelf.trays
      @history = ActivityLogQuery.shelf_history(@shelf)
    end
  end

  def associate
    @shelf = Shelf.find(params[:id])

    barcode = params[:barcode]

    if barcode == @shelf.barcode
      redirect_to shelves_path
      return
    end

    thickness = 1 # Because we don't care about thickness here, it just needs to be something valid.

    item = GetItemFromBarcode.call(barcode: barcode, user_id: current_user.id)

    if item.nil?
      flash[:error] = I18n.t("errors.barcode_not_found", barcode: barcode)
      redirect_to missing_shelf_item_path(id: @shelf.id)
      return
    end

    already = false

    if !item.shelf.nil?
      if item.shelf != @shelf
        flash[:error] = "Item #{barcode} is already assigned to #{item.shelf.barcode}."
        redirect_to wrong_shelf_item_path(id: @shelf.id, barcode: barcode)
        return
      else
        already = true
      end
    end

    begin
      AssociateShelfWithItemBarcode.call(current_user.id, @shelf, barcode, thickness)
      if already
        flash[:notice] = "Item #{barcode} already assigned to #{@shelf.barcode}. Record updated."
      else
        flash[:notice] = "Item #{barcode} stocked in #{@shelf.barcode}."
      end
      redirect_to show_shelf_path(id: @shelf.id)
      return
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to show_shelf_path(id: @shelf.id)
      return
    end
  end

  def wrong
    @shelf = Shelf.find(params[:id])
    @barcode = params[:barcode]
  end

  def missing
    @shelf = Shelf.find(params[:id])
  end

  def dissociate
    @shelf = Shelf.find(params[:id])
    @item = Item.find(params[:item_id])

    if params[:commit] == "Unstock"
      if UnstockItem.call(@item, current_user)
        redirect_to show_shelf_path(id: @shelf.id)
      else
        raise "unable to unstock item"
      end
    else
      if DissociateShelfFromItem.call(@item, current_user)
        redirect_to show_shelf_path(id: @shelf.id)
      else
        raise "unable to dissociate"
      end
    end
  end

  def check_trays_new
    @shelf = Shelf.new
  end
end
