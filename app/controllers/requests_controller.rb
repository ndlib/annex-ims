class RequestsController < ApplicationController
  def remove
    request = Request.find(params[:id])
    if DestroyRequest.call(request, current_user)
      ApiRemoveRequest.call(request: request)
      flash[:notice] = "Request removed"
    else
      flash[:error] = "Request NOT removed"
    end

    redirect_to :back
  end

  def sync
    requests = GetRequests.call
    flash[:notice] = I18n.t("requests.synchronized", count: requests.count)

    redirect_to :back
  end
end
