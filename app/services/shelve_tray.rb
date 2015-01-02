class ShelveTray
  attr_reader :tray

  def self.call(tray)
    new(tray).shelve!
  end

  def initialize(tray)
    @tray = tray
  end

  def shelve!
    validate_input!

    tray.shelved = true

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
