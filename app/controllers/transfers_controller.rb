class TransfersController < ApplicationController
  def show
    @transfer = Transfer.find(params[:id])
    @tray = Tray.new
  end

  def view_active
    @transfers = Transfer.all
  end

  # rubocop:disable Metrics/AbcSize
  def scan_tray
    @transfer = Transfer.find(params[:id])
    tray_barcode = params[:tray][:barcode]
    @tray = Tray.where(barcode: tray_barcode).take
    @shelf = Shelf.new

    if @tray.blank?
      flash[:error] = "Tray with barcode #{tray_barcode} does not exist."
      redirect_to transfer_path(id: params[:id])
      return
    end

    if !@transfer.shelf.trays.include?(@tray)
      flash[:error] = "Tray with barcode #{tray_barcode} is not accociated with this shelf. Rescan tray."
      redirect_to transfer_path(id: params[:id])
      return
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def transfer_tray
    @transfer = Transfer.find(params[:id])
    shelf_barcode = params[:shelf][:barcode]
    @shelf = Shelf.where(barcode: shelf_barcode).take
    @tray = Tray.find(params[:tray_id])
    tray_barcode = @tray.barcode

    if @shelf.blank?
      flash[:error] = "Shelf with barcode #{shelf_barcode} does not exist. Rescan tray."
      redirect_to transfer_path(id: params[:id])
      return
    end

    if dissociate_and_reassociate_tray(@tray, @shelf, @transfer.shelf)
      flash[:notice] = "Tray with barcode #{tray_barcode} transfered."
    else
      flash[:error] = "An error occured: " + @dissociate_error
    end

    if @transfer.shelf.trays.count == 0
      @transfer.destroy!
      redirect_to new_transfer_path
    else
      redirect_to transfer_path(id: params[:id])
    end
  end
  # rubocop:enable Metrics/AbcSize

  def new
    @transfer = Transfer.new
  end

  # rubocop:disable Metrics/AbcSize
  def create # rubocop:disable Metrics/AbcSize
    shelf_barcode = params[:transfer][:shelf][:barcode]
    shelf = Shelf.where(barcode: shelf_barcode).take
    if shelf.blank?
      flash[:error] = "Shelf with barcode #{shelf_barcode} does not exist."
      redirect_to new_transfer_path
      return
    end
    if shelf.trays.count == 0
      flash[:error] = "Shelf with barcode #{shelf_barcode} does not have any associated trays."
      redirect_to new_transfer_path
      return
    end
    transfer = BuildTransfer.call(shelf, current_user)
    redirect_to transfer_path(id: transfer.id)
  end
  # rubocop:enable Metrics/AbcSize

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
end
