class SearchController < ApplicationController
  def index
    @result = SearchItems.call(params)
    @params = params  # Because we need to fill in the form with previous values.

    if params[:commit] == 'Export'
      headers['Content-Disposition'] = "attachment; filename=\"item-list.csv\""
      headers['Content-Type'] ||= 'text/csv'

      render "index.csv"
      return
    else
      render "index"
      return
    end

  end

end
