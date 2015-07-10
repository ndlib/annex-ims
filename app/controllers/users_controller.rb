class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    user_id = params["user_id"]
    # If the checkbox was false on submit, the admin param will be null :(
    admin = params["admin"] || false
    user = User.find(user_id)
    if user
      user.admin = admin
      user.save!
    end
    redirect_to users_path
  end
end
