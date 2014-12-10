class TraysController < ApplicationController
  require 'barcode_prefix'
  include BarcodePrefix

  def index
    @tray = Tray.new
  end

  def scan
    begin
      @tray = Tray.where(barcode: params[:tray][:barcode]).first_or_create!
    rescue ActiveRecord::RecordInvalid => e
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

    if is_shelf(barcode)
      begin
        @shelf = Shelf.where(barcode: barcode).first_or_create!

        @tray.shelf = @shelf
        @tray.save!
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
      end
    end


    redirect_to show_tray_path(:id => @tray.id)
    return
  end

  # The only reason to get here is to set the tray's shelf to nil, so let's do that.
  def dissociate
    @tray = Tray.find(params[:id])

    if DissociateTray.call(@tray)
      redirect_to show_tray_path(:id => @tray.id)
    else
      raise "unable to dissociate tray"
    end
  end
end
