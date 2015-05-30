class ShelvesController < ApplicationController
  before_action :authenticate_user!

  def index
    @shelf = Shelf.new
  end

  def scan
    begin
      @shelf = GetShelfFromBarcode.call(params[:shelf][:barcode])
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to shelves_path
      return
    end
    redirect_to show_shelf_path(:id => @shelf.id)
  end

  def show
      @shelf = Shelf.find(params[:id])
  end

  def associate
    @shelf = Shelf.find(params[:id])

    barcode = params[:barcode]

    if barcode == @shelf.barcode
      redirect_to shelves_path
      return
    end

    thickness = 1 # Because we don't care about thickness here, it just needs to be something valid.

    item = GetItemFromBarcode.call(current_user.id, barcode)

    if item.nil?
      flash[:error] = "Item #{barcode} not found."
      redirect_to missing_shelf_item_path(:id => @tray.id)
      return
    end

    already = false

    if !item.shelf.nil?
      if item.shelf != @shelf
        flash[:error] = "Item #{barcode} is already assigned to #{item.shelf.barcode}."
        redirect_to wrong_shelf_item_path(:id => @shelf.id, :barcode => barcode)
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
      redirect_to show_shelf_path(:id => @shelf.id)
      return
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to show_shelf_path(:id => @shelf.id)
      return
    end
  end

  def wrong
    @shelf = Shelf.find(params[:id])
    @barcode = params[:barcode]
  end

  def dissociate
    @shelf = Shelf.find(params[:id])
    @item = Item.find(params[:item_id])

    if params[:commit] == 'Unstock'
      if UnstockItem.call(@item, current_user)
        redirect_to show_shelf_path(:id => @shelf.id)
      else
        raise "unable to unstock item"
      end
    else
      if DissociateShelfFromItem.call(@item, current_user)
        redirect_to show_shelf_path(:id => @shelf.id)
      else
        raise "unable to dissociate"
      end
    end
  end

end
