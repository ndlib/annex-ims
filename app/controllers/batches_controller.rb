class BatchesController < ApplicationController
  def index
    @data = {"draw" => params[:draw].to_i, "recordsTotal" => 1,
    "recordsFiltered" => 1, "data" => [{"rapid" => true, "shelf" => "SHELF-1234", "tray" => "TRAY-A1234", "title" => "Test", "author" => "Me", "chron" => "First"}]}
p @data.inspect
    respond_to do |format|
      format.html  # index.html.erb 
      format.json { render json: @data }
    end
  end

end
