class TraysController < ApplicationController
  def index
    @tray = Tray.new
  end

  def scan
    begin
      @tray = GetTrayFromBarcode.call(params[:tray][:barcode])
      @size = TraySize.call(@tray.barcode)
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to trays_path
      return
    end
    redirect_to show_tray_path(id: @tray.id)
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

    unless (params[:force] == "true")
      if !@tray.shelf.nil? && (@tray.shelf.barcode != barcode)
        flash[:error] = "#{@tray.barcode} belongs to #{@tray.shelf.barcode}, but #{barcode} was scanned."
        redirect_to wrong_shelf_path(id: @tray.id, barcode: barcode)
        return
      end
    end

    begin
      AssociateTrayWithShelfBarcode.call(@tray, barcode, current_user)
    rescue StandardError => e
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to show_tray_path(id: @tray.id)
      return
    end

    redirect_to trays_path
  end

  # The only reason to get here is to set the tray's shelf to nil, so let's do that.
  def dissociate
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    if DissociateTrayFromShelf.call(@tray, current_user)
      redirect_to trays_path
    else
      raise "unable to dissociate tray"
    end
  end

  def shelve
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    barcode = params[:barcode]

    unless (params[:force] == "true")
      if !@tray.shelf.nil? && (@tray.shelf.barcode != barcode)
        flash[:error] = "#{@tray.barcode} belongs to #{@tray.shelf.barcode}, but #{barcode} was scanned."
        redirect_to wrong_shelf_path(id: @tray.id, barcode: barcode)
        return
      end
    end

    if ShelveTray.call(@tray, current_user)
      redirect_to trays_path
    else
      raise "unable to shelve tray"
    end
  end

  def unshelve
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    if UnshelveTray.call(@tray, current_user)
      redirect_to trays_path
    else
      raise "unable to unshelve tray"
    end
  end

  # The only way to get here is if you've scanned the wrong shelf after scanning a tray
  def wrong_shelf
    @tray = Tray.find(params[:id])
    @barcode = params[:barcode]
  end

  # The only way to get here is if you've scanned the wrong item after scanning a tray
  def wrong_tray
    @tray = Tray.find(params[:id])
    @barcode = params[:barcode]
    @item = GetItemFromBarcode.call(barcode: @barcode, user_id: current_user.id)
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
      notify_airbrake(e)
      flash[:error] = e.message
      redirect_to trays_items_path
      return
    end
    redirect_to show_tray_item_path(id: @tray.id)
  end

  def show_item
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)
    @barcode = params[:barcode]
    @thickness = params[:thickness]
  end

  def associate_item
    @tray = Tray.find(params[:id])
    @size = TraySize.call(@tray.barcode)

    barcode = params[:barcode]
    thickness = params[:thickness]

    if barcode == @tray.barcode
      redirect_to trays_items_path
      return
    end

    unless IsValidThickness.call(thickness)
      flash[:error] = "select a valid thickness"
      redirect_to show_tray_item_path(id: @tray.id, barcode: barcode)
      return
    end

    # The system should validate the barcode against the stored regular expression(s)
    unless IsValidItem.call(barcode)
      flash[:error] = I18n.t("errors.barcode_not_valid", barcode: barcode)
      redirect_to invalid_tray_item_path(id: @tray.id, thickness: thickness, barcode: barcode)
      return
    end

    create_item(@tray, barcode, thickness)
  end

  def dissociate_item
    @tray = Tray.find(params[:id])
    @item = Item.find(params[:item_id])

    if params[:commit] == "Unstock"
      if UnstockItem.call(@item, current_user)
        redirect_to show_tray_item_path(id: @tray.id)
      else
        raise "unable to dissociate tray"
      end
    else
      if DissociateTrayFromItem.call(@item, current_user)
        redirect_to show_tray_item_path(id: @tray.id)
      else
        raise "unable to dissociate tray"
      end
    end
  end

  def withdraw
    @tray = Tray.find(params[:id])

    WithdrawTray.call(@tray, current_user)

    redirect_to show_tray_path(id: @tray.id)
  end

  def missing
    @tray = Tray.find(params[:id])
  end

  def invalid
    @tray = Tray.find(params[:id])
    @thickness = params[:thickness]
    @barcode = params[:barcode]
    @set_aside_flag = true
  end

  def create_item(tray = Tray.find(params[:id]), barcode = params[:barcode], thickness = params[:thickness])
    result = CreateItem.call(tray, barcode, current_user.id, thickness, params[:flag])

    if result == "errors.barcode_not_found"
      flash[:error] = I18n.t(result, barcode: barcode)
      redirect_to missing_tray_item_path(id: tray.id)
    elsif !result.nil?
      if result["Item #{barcode} is already assigned to"]
        flash[:error] = result
        redirect_to wrong_tray_path(id: tray.id, barcode: barcode)
      elsif result["Record updated."] || result["Item #{barcode} stocked in"]
        flash[:notice] = result
        if TrayFull.call(tray)
          flash[:error] = "warning - tray may be full"
        end
        redirect_to show_tray_item_path(id: tray.id)
      end
    else
      if !result.nil?
        notify_airbrake(result)
        flash[:error] = result.message
      end
      redirect_to show_tray_item_path(id: tray.id)
    end
  end

  def count_item
    @tray = Tray.find(params[:id])
    tray_count = (params[:tray_count])
    items = Item.select {|item| item.tray_id == @tray.id}

    if !tray_count.nil?
      if tray_count.to_i != items.count
        flash.now[:error] = "Manual and System Tray counts don't match! Try again."
      else
        redirect_to trays_items_path
      end
    end
  end
end
