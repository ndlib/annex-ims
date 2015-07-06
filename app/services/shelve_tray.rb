class ShelveTray
  attr_reader :tray, :user

  def self.call(tray, user)
    new(tray, user).shelve!
  end

  def initialize(tray, user)
    @tray = tray
    @user = user
  end

  def shelve!
    validate_input!

    tray.shelved = true

    if tray.save
      ActivityLogger.shelve_tray(tray: tray, shelf: tray.shelf, user: user)
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
