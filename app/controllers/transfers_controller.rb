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

    return if !check_for_blank_tray
    return if !check_for_tray_membership
  end

  def transfer_tray
    @transfer = Transfer.find(params[:id])
    @shelf = GetShelfFromBarcode.call(params[:shelf][:barcode])
    @tray = Tray.find(params[:tray_id])

    return if !check_for_blank_shelf("existing")

    dissociate_tray
    return if !check_for_final_tray
  end

  def new
    @transfer = Transfer.new
  end

  def create
    @shelf = get_existing_shelf

    return if !check_for_blank_shelf("new")
    return if !check_for_trays

    transfer = BuildTransfer.call(@shelf, current_user)
    redirect_to transfer_path(id: transfer.id)
  end

  def destroy
    returned_value = DestroyTransfer.call(Transfer.find(params[:id]), current_user)
    if  returned_value == "success"
      flash[:notice] = "Transfer canceled."
    else
      flash[:error] = "System Error: #{returned_value}. Transaction has been canceled. Please try again and/or open a support ticket."
    end
    redirect_to view_active_transfers_path
  end

  private

  def get_existing_shelf
    Shelf.where(barcode: params[:transfer][:shelf][:barcode]).take
  end

  def dissociate_and_reassociate_tray(tray, new_shelf, old_shelf)
    DissociateTrayFromShelf.call(tray, current_user)
    AssociateTrayWithShelfBarcode.call(tray, new_shelf.barcode, current_user)
  rescue StandardError => e
    AssociateTrayWithShelfBarcode.call(tray, old_shelf.barcode, current_user)
    UnshelveTray.call(tray, current_user)
    Raven.capture_exception(e)
    @dissociate_error = e.message
    false
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
      assign_error_message("tray_blank", @tray)
      redirect_to transfer_path(id: params[:id])
      return false
    end
    true
  end

  def check_for_tray_membership
    if !@transfer.shelf.trays.include?(@tray)
      assign_error_message("tray_not_associated", @tray)
      redirect_to transfer_path(id: params[:id])
      return false
    end
    true
  end

  def check_for_blank_shelf(type)
    if @shelf.blank?
      flash[:error] = "Shelf with barcode #{params[:transfer][:shelf][:barcode]} does not exist. Please rescan."
      if type == "new"
        redirect_to new_transfer_path
        return false
      else
        redirect_to transfer_path(id: params[:id])
        return false
      end
    end
    true
  end

  def check_for_final_tray
    if @transfer.shelf.trays.count == 0
      DestroyTransfer.call(@transfer, current_user)
      redirect_to new_transfer_path
      return false
    else
      redirect_to transfer_path(id: params[:id])
      return false
    end
    true
  end

  def check_for_trays
    if @shelf.trays.count == 0
      flash[:error] = "Shelf with barcode #{@shelf.barcode} does not have any associated trays."
      redirect_to new_transfer_path
      return false
    end
    true
  end

  def dissociate_tray
    if dissociate_and_reassociate_tray(@tray, @shelf, @transfer.shelf)
      flash[:notice] = "Tray with barcode #{@tray.barcode} transfered to shelf #{@shelf.barcode}."
    else
      flash[:error] = "An error occured: " + @dissociate_error
    end
  end
end
