class ItemsController < ApplicationController
  def index
    @item = Item.new
  end

  def scan
    begin
      @item = GetItemFromBarcode.call(params[:item][:barcode])
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to items_path
      return
    end
    redirect_to show_item_path(:id => @item.id)
  end

  def show
    @item = Item.find(params[:id])
  end

end
