class TraysController < ApplicationController
  require 'barcode_prefix'
  include BarcodePrefix

  def index
    @tray = Tray.new
  end

  def scan
    @tray = Tray.where(barcode: params[:tray][:barcode]).first_or_create!
    redirect_to show_trays_path(:id => @tray.id)
  end

  def show
    @tray = Tray.find(params[:id])
  end
end
