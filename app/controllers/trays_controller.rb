class TraysController < ApplicationController
  def index
    @tray = Tray.new
  end

  def scan
    begin
      @tray = GetTrayFromBarcode.call(params[:tray][:barcode])
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to trays_path
      return
    end
    redirect_to show_tray_path(:id => @tray.id)
  end

  def show
    @tray = Tray.find(params[:id])
  end

  def associate
    @tray = Tray.find(params[:id])

    barcode = params[:barcode]

    if AssociateTrayWithShelfBarcode.call(@tray, barcode)
      redirect_to show_tray_path(:id => @tray.id)
      return
    else
      raise "unable to process barcode"
    end

    redirect_to show_tray_path(:id => @tray.id)
    return
  end

  # The only reason to get here is to set the tray's shelf to nil, so let's do that.
  def dissociate
    @tray = Tray.find(params[:id])

    if DissociateTrayFromShelf.call(@tray)
      redirect_to show_tray_path(:id => @tray.id)
    else
      raise "unable to dissociate tray"
    end
  end

  # Should this area be pulled out into a separate controller? It's all about trays, but with items. 
  def items
    @tray = Tray.new
  end

  def scan_item
    begin
      @tray = GetTrayFromBarcode.call(params[:tray][:barcode])
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to trays_path
      return
    end
    redirect_to show_tray_item_path(:id => @tray.id)
  end

  def show_item
    @tray = Tray.find(params[:id])
  end

  def associate_item
    @tray = Tray.find(params[:id])

    barcode = params[:barcode]
    if IsValidThickness.call(params[:thickness])
      thickness = params[:thickness]
    else
      flash[:error] = 'select a valid thickness'
      redirect_to show_tray_item_path(:id => @tray.id)
      return
    end

    if AssociateTrayWithItemBarcode.call(@tray, barcode, thickness)
      redirect_to show_tray_item_path(:id => @tray.id)
      return
    else
      raise "unable to process barcode"
    end

    redirect_to show_tray_path(:id => @tray.id)
    return
  end

  def dissociate_item
    @tray = Tray.find(params[:id])
    @item = Item.find(params[:item_id])

    if DissociateTrayFromItem.call(@item)
      redirect_to show_tray_item_path(:id => @tray.id)
    else
      raise "unable to dissociate tray"
    end
  end
end
