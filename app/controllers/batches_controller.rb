class BatchesController < ApplicationController
  def index
    requests = Request.all
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
      @batch = BuildBatch.call(params[:batch])

      flash[:notice] = "Batch created."

      redirect_to root_path
      return
    end
  end

end
