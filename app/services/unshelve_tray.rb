class UnshelveTray
  attr_reader :tray, :user

  def self.call(tray, user)
    new(tray, user).unshelve!
  end

  def initialize(tray, user)
    @tray = tray
    @user = user
  end

  def unshelve!
    validate_input!

    tray.shelved = false

    if tray.save
      LogActivity.call(tray, "Unshelved", tray.shelf, Time.now, user)
      tray
    else
      false
    end
  end

  private

    def validate_input!
      if IsObjectTray.call(tray)
        true
      else
        raise "object is not a tray"
      end
    end

  end
