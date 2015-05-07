class BatchesController < ApplicationController
  before_action :authenticate_user!

  def index
    GetRequests.call(current_user.id) # This should go in a queue or scheduler to run periodically.
    requests = Request.all.where("id NOT IN (SELECT request_id FROM matches)")
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

  def current
    @batch = current_user.batches.where(active: true).first
  end

  def remove
    if !params[:match_id].blank?
      match = Match.find(params[:match_id])
      if !match.blank?
        match.destroy!
      end
    end

    redirect_to current_batch_path
  end
end
