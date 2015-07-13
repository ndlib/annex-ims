class ApplicationController < ActionController::Base
  before_action :check_authentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def check_authentication
    unless user_signed_in?
      redirect_to_sign_in
      return
    end
    unless user_admin?
      redirect_to_unauthorized
      return
    end
  end

  def redirect_to_sign_in
    redirect_to new_user_session_path
  end

  def redirect_to_unauthorized
    raise_404
  end

  def raise_404(message = "Not Found")
    fail ActionController::RoutingError.new(message)
  end

  def user_admin?
    config_admin = ""
    if Rails.configuration.respond_to? :admin_user_name
      config_admin = Rails.configuration.admin_user_name
    end
    current_user.admin || (config_admin == current_user.username)
  end
end
