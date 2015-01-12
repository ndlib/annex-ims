class SearchController < ApplicationController
  def index
    @result = Item.find([1, 10])
  end

end
