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

  def retrieve
    @batch = current_user.batches.where(active: true).first
    @match = @batch.current_match

    if @match.nil? # then we're done processing matches
      redirect_to finalize_batch_path
      return
    end

  end

  def item
    @batch = current_user.batches.where(active: true).first
    @match = @batch.current_match

    if params[:commit] == "Skip"
      @match.processed = "skipped"
      @match.save!

      redirect_to retrieve_batch_path
      return
    else
      if params[:barcode] != @match.item.barcode
        flash[:error] = "Wrong item scanned."

        redirect_to retrieve_batch_path
        return
      else
        flash[:notice] = "Item #{@match.item.barcode} scanned."
        redirect_to bin_batch_path
        return
      end

    end
  end

  def bin
    @batch = current_user.batches.where(active: true).first
    @match = @batch.current_match

  end

  def scan_bin
    @batch = current_user.batches.where(active: true).first
    @match = @batch.current_match

    if params[:commit] == "Skip"
      @match.processed = "skipped"
      @match.save!

      redirect_to retrieve_batch_path
      return
    else
      barcode = params[:barcode]
      if !IsBinBarcode.call(barcode)
        flash[:error] = "#{barcode} is not a bin, please try again."
        redirect_to bin_batch_path
        return
      else
        if BinType.call(barcode) != @match.request.bin_type
          flash[:error] = "#{barcode} is not the correct type, please try again."
          redirect_to bin_batch_path
          return
        else # success!
          @bin = GetBinFromBarcode.call(barcode)
          @match.item.bin = @bin
          @match.item.save!
          AcceptMatch.call(@match)

          flash[:notice] = "Item #{@match.item.barcode} is now in bin #{barcode}."
          redirect_to retrieve_batch_path # on to the next item in the batch
          return
        end
      end
    end

  end

  def finalize
    @batch = current_user.batches.where(active: true).first
    @matches = @batch.skipped_matches
  end

  def finish
    @batch = current_user.batches.where(active: true).first
    FinishBatch.call(@batch)
    flash[:notice] = "Finished processing batch, ready to begin a new batch."
    redirect_to batches_path
  end
end
