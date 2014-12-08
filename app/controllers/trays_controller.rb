class TraysController < ApplicationController
  def index
    @tray = Tray.new
  end

  def scan
    @tray = Tray.where(barcode: params[:barcode]).first_or_create
    redirect_to show_trays_path(:id => @tray.id)
  end

  def show
    @tray = Tray.where(barcode: params[:barcode]).first
  end
end
