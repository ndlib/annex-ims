class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @res = SearchItems.call(params)
    @results = @res.results
    @total = @res.total
    @params = params  # Because we need to fill in the form with previous values.
    @criteria = params[:criteria]
    @criteria_type = params[:criteria_type]
  end

  def req
    if Disposition.pluck(:id).include?(params[:disposition_id].to_i)
      params[:items].keys.each do |item_id|
        item = Item.find(item_id)
        request = BuildDeaccessioningRequest.call(item_id,
                                                  params[:disposition_id],
                                                  params[:comment])[0]
        if !item.stocked?
          DeaccessionNotStockedItem.call(request.id, item_id, params[:disposition_id], current_user)
        end
      end
      redirect_to batches_path and return
    else
      flash[:error] = "Select a Disposition"
      redirect_to deaccessioning_path(params) and return
    end
  end
end
