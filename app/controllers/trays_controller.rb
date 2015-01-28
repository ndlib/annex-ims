class TraysController < ApplicationController
  def index
    @tray = Tray.new
  end

  def scan
    begin
      @tray = GetTrayFromBarcode.call(params[:tray][:barcode])
      @size = TraySize.call(@tray.barcode)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to trays_path
      return
    end
    redirect_to show_tray_path(:id => @tray.id)
  end

  def show
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)
  end

  def associate
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    barcode = params[:barcode]

    if barcode == @tray.barcode
      redirect_to trays_path
      return
    end

    if !@tray.shelf.nil? and (@tray.shelf.barcode != barcode)
      flash[:error] = "#{@tray.barcode} belongs to #{@tray.shelf.barcode}, but #{barcode} was scanned."
      redirect_to wrong_tray_path(:id => @tray.id)
      return
    end

    begin
      AssociateTrayWithShelfBarcode.call(@tray, barcode)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to show_tray_path(:id => @tray.id)
      return
    end

    redirect_to trays_path
    return
  end

  # The only reason to get here is to set the tray's shelf to nil, so let's do that.
  def dissociate
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    if DissociateTrayFromShelf.call(@tray)
      redirect_to trays_path
    else
      raise "unable to dissociate tray"
    end
  end

  def shelve
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    if ShelveTray.call(@tray)
      redirect_to trays_path
    else
      raise "unable to shelve tray"
    end
  end

  def unshelve
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    if UnshelveTray.call(@tray)
      redirect_to show_tray_path(:id => @tray.id)
    else
      raise "unable to unshelve tray"
    end
  end

  # The only way to get here is if you've scanned the wrong shelf after scanning a tray
  def wrong
    @tray = Tray.find(params[:id])
  end

  # Should this area be pulled out into a separate controller? It's all about trays, but with items. 
  def items
    @tray = Tray.new
  end

  def scan_item
    begin
      @tray = GetTrayFromBarcode.call(params[:tray][:barcode])
      @size = TraySize.call(@tray.barcode)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to trays_items_path
      return
    end
    redirect_to show_tray_item_path(:id => @tray.id)
  end

  def show_item
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)
    @barcode = params[:barcode]
  end

  def associate_item
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    barcode = params[:barcode]

    if barcode == @tray.barcode
      redirect_to trays_items_path
      return
    end


    if IsValidThickness.call(params[:thickness])
      thickness = params[:thickness]
    else
      flash[:error] = 'select a valid thickness'
      redirect_to show_tray_item_path(:id => @tray.id, :barcode => barcode)
      return
    end

    begin
      AssociateTrayWithItemBarcode.call(@tray, barcode, thickness)
      flash[:notice] = "Item #{barcode} associated with Tray #{@tray.barcode}."
      if TrayFull.call(@tray)
        flash[:error] = 'warning - tray may be full'
      end
      redirect_to show_tray_item_path(:id => @tray.id)
      return
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to show_tray_item_path(:id => @tray.id)
      return
    end

    redirect_to show_tray_path(:id => @tray.id)
    return
  end

  def dissociate_item
    @tray = Tray.find(params[:id])
    @item = Item.find(params[:item_id])
    @size = TraySize.call(@tray.barcode)

    if DissociateTrayFromItem.call(@item)
      redirect_to show_tray_item_path(:id => @tray.id)
    else
      raise "unable to dissociate tray"
    end
  end

  def withdraw
    @tray = Tray.find(params[:id])

    WithdrawTray.call(@tray)

    redirect_to show_tray_path(:id => @tray.id)
    return
  end
end
