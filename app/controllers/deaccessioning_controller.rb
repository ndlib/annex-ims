class DeaccessioningController < ApplicationController
  before_action :require_admin

  def index
    @params = params  # Because we need to fill in the form with previous values.
  end
end
