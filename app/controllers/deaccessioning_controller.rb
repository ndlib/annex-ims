class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @res = SearchItems.call(params)
    @results = @res.results
    @total = @res.total
    @params = params  # Because we need to fill in the form with previous values.
  end

  def req
    if Disposition.pluck(:id).include?(params[:disposition_id])
      params[:items].keys.each do |item_id|
        item = Item.find(item_id)
        if item.unstocked?
          bin = GetBinFromBarcode.call("BIN-DEAC-HAND-01")
          SetItemDisposition.call(item_id, params[:disposition_id])
          item.bin = bin
          item.save!
          ActivityLogger.associate_item_and_bin(item: item, bin: bin, user: current_user)
        else
          BuildDeaccessioningRequest.call(item_id,
                                          params[:disposition_id],
                                          params[:comment])
        end
      end
      redirect_to batches_path
    else
      flash[:error] = "Select a Disposition"
      redirect_to deaccessioning_path
    end
  end
end
