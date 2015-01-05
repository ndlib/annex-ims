class ItemsController < ApplicationController
  def index
    @item = Item.new
  end

  def scan
    begin
      @item = GetItemFromBarcode.call(params[:item][:barcode])
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to items_path
      return
    end
    redirect_to show_item_path(:id => @item.id)
  end

  def show
    @item = Item.find(params[:id])
  end

  # I don't like multi-purpose methods, but there's no other way to do this, hence the name.
  def multex
    @item = Item.find(params[:id])
    barcode = params[:barcode]

    if IsItemBarcode.call(barcode) # treat it just like you scanned a fresh item as in 'scan'
      begin
        @item = GetItemFromBarcode.call(barcode)
      rescue StandardError => e
        flash[:error] = e.message
        redirect_to items_path
        return
      end
      redirect_to show_item_path(:id => @item.id)
    elsif IsTrayBarcode.call(barcode) # if this is a tray, do other stuff
      begin
        @tray = GetTrayFromBarcode.call(barcode)
        if (!@item.tray.nil?) && (@item.tray != @tray) # this isn't the place to be putting items in the wrong tray
          raise 'incorrect tray for this item'
        end
        StockItem.call(@item)
        flash[:notice] = "Item #{@item.barcode} stocked."
        redirect_to items_path
        return
      rescue StandardError => e
        flash[:error] = e.message
        redirect_to show_item_path(:id => @item.id)
        return
      end
    else
      flash[:error] = "scan either a new item or a tray to stock to"
      redirect_to show_item_path(:id => @item.id)
      return
    end

  end

end
