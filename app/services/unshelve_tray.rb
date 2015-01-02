class UnshelveTray
  attr_reader :tray

  def self.call(tray)
    new(tray).unshelve!
  end

  def initialize(tray)
    @tray = tray
  end

  def unshelve!
    validate_input!

    tray.shelved = false

    if tray.save
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
