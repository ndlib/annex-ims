module GetUserType
  def self.call(user)
    if user.admin == true && user.worker == false
      "admin"
    elsif user.admin == false && user.worker == true
      "worker"
    elsif user.admin == false && user.worker == false
      "disabled"
    end
  end
end
