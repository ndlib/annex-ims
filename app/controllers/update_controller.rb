class UpdateController < ApplicationController
  before_action :require_admin

  def index
    @old_item = Item.new
  end
end
