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

  def params_whitelist
    # TODO: :items does not work. In Rails 5.1+, we can do :items => {} to permit a hash as a param.
    params.permit([:items, :disposition_id, :comment])
  end

  def req
    if Disposition.pluck(:id).include?(params[:disposition_id].to_i)
      if params[:items].blank?
        flash[:error] = I18n.t("deaccessioning.status.empty_items")
        redirect_to deaccessioning_path(params_whitelist) and return
      else
        items = Item.where(id: params[:items].keys)
        items.each do |item|
          request = BuildDeaccessioningRequest.call(item.id,
                                                    params_whitelist[:disposition_id],
                                                    params_whitelist[:comment])[0]
          if !item.stocked?
            DeaccessionNotStockedItem.call(request.id, item.id, params_whitelist[:disposition_id], current_user)
          end
        end
        redirect_to deaccessioning_path() and return
      end
    else
      flash[:error] = "Select a Disposition"
      redirect_to deaccessioning_path(params_whitelist) and return
    end
  end
end
