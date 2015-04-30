class BatchesController < ApplicationController
  before_action :authenticate_user!

  def index
    GetRequests.call(current_user.id) # This should go in a queue or scheduler to run periodically.
    requests = Request.all.where(batch_id: nil)
    @data = BuildRequestData.call(requests)

    respond_to do |format|
      format.html  # index.html.erb 
    end
  end

  def create
    if params[:batch].blank?
      flash[:error] = "No items selected."

      redirect_to batches_path
      return
    else
      @batch = BuildBatch.call(params[:batch], current_user)

      flash[:notice] = "Batch created."

      redirect_to root_path
      return
    end
  end

end
