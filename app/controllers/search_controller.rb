class SearchController < ApplicationController
  def index
    @result = SearchItems.call(params)
  end

end
