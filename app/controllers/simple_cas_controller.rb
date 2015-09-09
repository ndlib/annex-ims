class SimpleCasController < Devise::CasSessionsController
  # Rails <= 3 skip_before_filter :redirect_to_sign_in, only: [:new]
  skip_before_action :check_authentication, only: [:new]
  skip_before_action :require_no_authentication, only: [:new, :create]
  skip_before_action :check_activity, only: [:new, :service]
  before_action :update_activity, only: [:service]
end
