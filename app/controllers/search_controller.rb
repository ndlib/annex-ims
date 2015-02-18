class SearchController < ApplicationController
  def index
    @result = SearchItems.call(params)
    @params = params  # Because we need to fill in the form with previous values.
  end

end
