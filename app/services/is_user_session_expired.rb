class IsUserSessionExpired
  def self.call(user:)
    new.expired?(user: user)
  end

  def expired?(user:)
    if user.last_activity_at.present?
      timeout = 15.minutes
      if Rails.configuration.respond_to? :user_timeout
        timeout = Rails.configuration.user_timeout
      end
      Time.now - user.last_activity_at > timeout
    else
      true
    end
  end
end
