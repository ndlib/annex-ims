class RequestsController < ApplicationController

  def remove
    request = Request.find(params[:request_id])
    if (DestroyRequest.call(request, current_user))
      ApiRemoveRequest.call(request)
      flash[:notice] = 'Request removed'
    else
      flash[:error] = 'Request NOT removed'
    end

    redirect_to :back
    
  end

end
