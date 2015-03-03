class BatchesController < ApplicationController
  def index
    requests = Request.all
    @data = BuildRequestData.call(requests)

    respond_to do |format|
      format.html  # index.html.erb 
    end
  end

end
