class ReportsController < ApplicationController
  def call_report
    barcode = params[:report][:barcode]

    if IsItemBarcode.call(barcode)
      redirect_to item_detail_path(barcode)
    elsif IsTrayBarcode.call(barcode)
      redirect_to tray_detail_path(barcode)
    elsif IsShelfBarcode.call(barcode)
      redirect_to shelf_detail_path(barcode)
    else
      redirect_to bin_detail_path(barcode)
    end
  end
end
