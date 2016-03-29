module GetUserType
  def self.call(user)
    if user.admin == true && user.worker == false
      return "admin"
    elsif user.admin == false && user.worker == true
      return "worker"
    elsif user.admin == false && user.worker == false
      return "disabled"
    end
  end
end
