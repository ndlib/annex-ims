class TrayTypesController < ApplicationController
  before_action :require_admin
  before_action :set_tray_type, only: [:show, :edit, :update, :destroy, :activation]

  respond_to :html

  def index
    @tray_types = TrayType.all
    respond_with(@tray_types)
  end

  def show
    respond_with(@tray_type)
  end

  def new
    @tray_type = TrayType.new
    respond_with(@tray_type)
  end

  def edit
  end

  def create
    @tray_type = TrayType.new(tray_type_params)
    @tray_type.save
    respond_with(@tray_type)
  end

  def update
    @tray_type.update(tray_type_params)
    respond_with(@tray_type)
  end

  def destroy
    @tray_type.destroy
    respond_with(@tray_type)
  end

  def activation
    if @tray_type.active
      if @tray_type.trays.count == 0
        @tray_type.active = false
      else
        raise 'unable to deactivate tray type with associated trays'
      end
    else
      @tray_type.active = true
    end
    @tray_type.save
    redirect_to tray_types_path
  end

  private
    def set_tray_type
      @tray_type = TrayType.find(params[:id])
    end

    def tray_type_params
      params.require(:tray_type).permit(:code, :trays_per_shelf, :unlimited, :height, :capacity, :active)
    end
end
