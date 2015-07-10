class ApplicationController < ActionController::Base
  before_action :redirect_to_sign_in, unless: :user_signed_in?
  before_action :redirect_to_unauthorized, unless: :user_admin?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def redirect_to_sign_in
    redirect_to new_user_session_path
  end

  def redirect_to_unauthorized
    raise_404("User not an admin")
  end

  def raise_404(message = "Not Found")
    fail ActionController::RoutingError.new(message)
  end

  def user_admin?
    current_user.admin
  end
end
