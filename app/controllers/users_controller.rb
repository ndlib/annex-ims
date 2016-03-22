class UsersController < ApplicationController
  before_action :require_admin
  def index
    @users = User.all
  end

  def create
    user_name = params["user_name"]
    if User.exists?(username: user_name)
      flash[:error] = "User already exists"
    else
      user = User.new(username: user_name)
      user.save!
    end
    redirect_to users_path
  end

  def update
    user_id = params["user_id"]
    user = User.find(user_id)
    if user
      # If the admin was selected, then user is set to admin and otherwise to worker
      if params["user_type"] == "admin"
        user.admin = true
        user.worker = false
      # If the worker was selected, then user is set to worker and otherwise to disabled
      elsif params["user_type"] == "worker"
        user.admin = false
        user.worker = true
      else
        user.admin = false
        user.worker = false
      end
      user.save!
      flash[:notice] = "#{user.username}'s status is updated to #{params["user_type"]}."
    end
    redirect_to users_path
  end
end
