class ShelvesController < ApplicationController
  def index
    @shelf = Shelf.new
  end

  def scan
    begin
      @shelf = GetShelfFromBarcode.call(params[:shelf][:barcode])
    rescue StandardError => e
      Raven.capture_exception(e)
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
      Raven.capture_exception(e)
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

  def check_trays_find
    begin
      @shelf = GetShelfFromBarcode.call(params[:shelf][:barcode])
      @scanned = []
      @extras = []
    rescue StandardError => e
      Raven.capture_exception(e)
      flash[:error] = e.message
      redirect_to check_trays_new_path
      return
    end
    redirect_to check_trays_path(barcode: @shelf.barcode)
  end

  def check_trays
    @shelf = Shelf.where(barcode: params[:barcode]).take
    @scanned = []
    @extras = []
  end

  def validate_trays
    @shelf = Shelf.where(barcode: params[:barcode]).take
    tray_barcode = params[:tray_barcode]
    tray = Tray.where(barcode: tray_barcode).take
    @scanned = params[:scanned].present? ? params[:scanned] : []
    @extras = params[:extras].present? ? params[:extras] : []

    if tray.nil?
      if IsTrayBarcode.call(tray_barcode)
        errors = build_extras_errors(@extras)
        errors.push(I18n.t("errors.barcode_not_found", barcode: tray_barcode))
        flash.now[:error] = errors.join("<br>").html_safe if errors.count > 0
        tray = Tray.create!(barcode: tray_barcode)
        ActivityLogger.create_tray(tray: tray, user: current_user)
      else
        errors = build_extras_errors(@extras)
        errors.push(I18n.t("errors.barcode_not_valid", barcode: tray_barcode))
        flash.now[:error] = errors.join("<br>").html_safe if errors.count > 0
      end
      render :check_trays
      return
    end

    if @shelf.trays.include?(tray)
      @scanned.push(tray_barcode)
      @scanned = @scanned.uniq
      errors = build_extras_errors(@extras)
      flash.now[:error] = errors.join("<br>").html_safe if errors.count > 0
    else
      @extras.push(tray_barcode)
      @extras = @extras.uniq.sort!
      but_message = tray.shelf.present? ? "but is associated with shelf '#{tray.shelf.barcode}'" : "but is not associated with a shelf."
      errors = build_extras_errors(@extras)
      flash.now[:error] = errors.join("<br>").html_safe if errors.count > 0
    end

    render :check_trays
  end

  def build_extras_errors(extras)
    errors = []
    if extras.count > 0
      errors = extras.map { |extra| I18n.t("errors.barcode_not_associated_to_shelf", barcode: extra) }
    end
    return errors
  end
end
