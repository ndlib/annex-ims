include Warden::Test::Helpers

module AuthenticationHelper
  def login_user
    @user = FactoryGirl.create(:user)
    login_as @user, scope: :user
    @user
  end

=begin - placeholder, because we will need this and I will forget otherwise
  def login_admin
    @user = XXX Do something special for admins
    sign_in(@user)
  end
=end

  def logout
    sign_out(@user)
  end
end
