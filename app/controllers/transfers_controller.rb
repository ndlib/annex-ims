class TransfersController < ApplicationController
  def show
    @transfer = Transfer.find(params[:id])
    @tray = Tray.new
  end

  def view_active
    @transfers = Transfer.all
  end

  def scan_tray
    @transfer = Transfer.find(params[:id])
    @tray = Tray.where(barcode: params[:tray][:barcode]).take
    @shelf = Shelf.new

    check_for_blank_tray
    check_for_tray_membership
  end

  def transfer_tray
    @transfer = Transfer.find(params[:id])
    @shelf = Shelf.where(barcode: params[:shelf][:barcode]).take
    @tray = Tray.find(params[:tray_id])

    check_for_blank_shelf("existing")
    dissociate_tray
    check_for_final_tray
  end

  def new
    @transfer = Transfer.new
  end

  def create
    @shelf = Shelf.where(barcode: params[:transfer][:shelf][:barcode]).take

    check_for_blank_shelf("new")
    check_for_trays

    transfer = BuildTransfer.call(@shelf, current_user)
    redirect_to transfer_path(id: transfer.id)
  end

  private

  def dissociate_and_reassociate_tray(tray, new_shelf, old_shelf)
    DissociateTrayFromShelf.call(tray, current_user)
    AssociateTrayWithShelfBarcode.call(tray, new_shelf.barcode, current_user)
  rescue StandardError => e
    AssociateTrayWithShelfBarcode.call(tray, old_shelf.barcode, current_user)
    UnshelveTray.call(tray, current_user)
    @dissociate_error = e.message
    false
  end

  def assign_class_variables(transfer = Transfer.new, tray = Tray.new, shelf = Shelf.new)
    @transfer = transfer
    @tray = tray
    @shelf = shelf
  end

  def assign_error_message(type, object)
    case type
    when "tray_blank"
      flash[:error] = "Tray with barcode #{object.barcode} does not exist."
    when "tray_not_associated"
      flash[:error] = "Tray with barcode #{object.barcode} is not accociated with this shelf. Rescan tray."
    end
  end

  def check_for_blank_tray
    if @tray.blank?
      assign_error_message("tray_blamk", @tray)
      redirect_to transfer_path(id: params[:id])
      return
    end
  end

  def check_for_tray_membership
    if !@transfer.shelf.trays.include?(@tray)
      assign_error_message("tray_not_associated", @tray)
      redirect_to transfer_path(id: params[:id])
      return
    end
  end

  def check_for_blank_shelf(type)
    if @shelf.blank?
      flash[:error] = "Shelf with barcode #{params[:shelf][:barcode]} does not exist. Please rescan."
      if type == "new"
        redirect_to transfer_path(id: params[:id])
      else
        redirect_to new_transfer_path
      end
      return
    end
  end

  def check_for_final_tray
    if @transfer.shelf.trays.count == 0
      @transfer.destroy!
      redirect_to new_transfer_path
    else
      redirect_to transfer_path(id: params[:id])
    end
  end

  def check_for_trays
    if @shelf.trays.count == 0
      flash[:error] = "Shelf with barcode #{@shelf.barcode} does not have any associated trays."
      redirect_to new_transfer_path
      return
    end
  end

  def dissociate_tray
    if dissociate_and_reassociate_tray(@tray, @shelf, @transfer.shelf)
      flash[:notice] = "Tray with barcode #{@tray.barcode} transfered to shelf #{@transfer.shelf.barcode}."
    else
      flash[:error] = "An error occured: " + @dissociate_error
    end
  end
end
