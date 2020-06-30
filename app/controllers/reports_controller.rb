# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy export]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    output = BuildReport.call(
      @report.fields,
      @report.start_date,
      @report.end_date,
      @report.activity,
      @report.request_status,
      @report.item_status
    )
    @results = output[:results]
    @sql = output[:sql]

    @report.fields << 'activity'
  end

  def export
    output = BuildReport.call(
      @report.fields,
      @report.start_date,
      @report.end_date,
      @report.activity,
      @report.request_status,
      @report.item_status
    )

    @results = output[:results]
    @sql = output[:sql]

    @report.fields << 'activity'

    headers['Content-Disposition'] = \
      "attachment; filename=\"#{@report.name}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render 'export.csv'
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit; end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report
    @report = Report.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def report_params
    preprocess_start_date(params)
    preprocess_end_date(params)

    params.require(:report).permit(:name, :start_date, :end_date, :activity, :request_status, :item_status, fields: [])
  end

  def preprocess_start_date(params)
    if params[:report]['start_date(1i)'].present?
      params[:report]['start_date'] = Date.new(
        params[:report]['start_date(1i)'].to_i,
        params[:report]['start_date(2i)'].present? ? params[:report]['start_date(2i)'].to_i : 1,
        params[:report]['start_date(3i)'].present? ? params[:report]['start_date(3i)'].to_i : 1
      ).to_s

      params[:report].delete('start_date(1i)')
      params[:report].delete('start_date(2i)')
      params[:report].delete('start_date(3i)')
    end

    params
  end

  def preprocess_end_date(params)
    if params[:report]['end_date(1i)'].present?
      year = params[:report]['end_date(1i)'].to_i
      month = params[:report]['end_date(2i)'].present? ? params[:report]['end_date(2i)'].to_i : 12
      day = if params[:report]['end_date(3i)'].present? && params[:report]['end_date(3i)'].to_i <= Time.days_in_month(month, year)
              params[:report]['end_date(3i)'].to_i
            else
              Time.days_in_month(month, year)
            end

      params[:report]['end_date'] = Date.new(
        year,
        month,
        day
      ).to_s

      params[:report].delete('end_date(1i)')
      params[:report].delete('end_date(2i)')
      params[:report].delete('end_date(3i)')
    end
    params
  end
end
