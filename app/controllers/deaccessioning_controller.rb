class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @res = SearchItems.call(params)
    @results = @res.results
    @total = @res.total
    @params = params  # Because we need to fill in the form with previous values.
  end

  def req
    if Disposition.pluck(:id).include?(params[:disposition_id].to_i)
      if params[:items].blank?
        flash[:error] = "No items were selected to create a deaccessioning request."
	params.delete(:action)
	params.delete(:controller)
        redirect_to deaccessioning_path(params) and return
      else
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
      end
    else
      flash[:error] = "Select a Disposition"
      redirect_to deaccessioning_path and return
    end
  end
end
