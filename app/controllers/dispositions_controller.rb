class DispositionsController < ApplicationController
  before_action :set_disposition, only: [:show, :edit, :update, :destroy]
  before_action :require_admin

  respond_to :html

  def index
    @dispositions = Disposition.all
    respond_with(@dispositions)
  end

  def show
    respond_with(@disposition)
  end

  def new
    @disposition = Disposition.new
    respond_with(@disposition)
  end

  def edit
  end

  def create
    @disposition = Disposition.new(disposition_params)
    @disposition.save
    respond_with(@disposition)
  end

  def update
    @disposition.update(disposition_params)
    respond_with(@disposition)
  end

  def destroy
    @disposition.destroy
    respond_with(@disposition)
  end

  private
    def set_disposition
      @disposition = Disposition.find(params[:id])
    end

    def disposition_params
      params.require(:disposition).permit(:code, :description, :active)
    end
end
