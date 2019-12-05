module AuthenticationHelper
  include Warden::Test::Helpers

  def self.included(spec)
    spec.after do
      Warden.test_reset!
    end
  end

  def login_admin
    @user = FactoryBot.create(:user, admin: true)
    login_as @user, scope: :user
    @user
  end

  def login_worker
    @user = FactoryBot.create(:user, admin: false, worker: true)
    login_as @user, scope: :user
    @user
  end

  # - placeholder, because we will need this and I will forget otherwise
  #   def login_admin
  #     @user = XXX Do something special for admins
  #     sign_in(@user)
  #   end

  def logout
    sign_out(@user)
  end
end
