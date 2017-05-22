class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @res = SearchItems.call(params)
    @results = @res.results
    @total = @res.total
    @params = params  # Because we need to fill in the form with previous values.
  end

  def req
    params[:items].keys.each do |item_id|
      item = Item.find(item_id)
      if item.stocked?
        BuildDeaccessioningRequest.call(item_id,
                                        params[:disposition_id],
                                        params[:comment])
      else
        bin = GetBinFromBarcode.call("BIN-DEAC-HAND-01")
	SetItemDisposition.call(item_id, params[:disposition_id])
	item.bin = bin
	item.save!
	ActivityLogger.associate_item_and_bin(item: item, bin: bin, user: current_user)
      end
    end
    redirect_to batches_path
  end
end
