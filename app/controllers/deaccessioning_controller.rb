class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @res = SearchItems.call(params)
    @results = @res.results
    @total = @res.total
    @params = params  # Because we need to fill in the form with previous values.
  end

  def req
    params[:items].keys.each do |item_id|
      BuildDeaccessioningRequest.call(item_id)
    end
    redirect_to batches_path
  end
end
