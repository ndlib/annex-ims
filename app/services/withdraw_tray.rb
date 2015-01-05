class WithdrawTray
  attr_reader :tray

  def self.call(tray)
    new(tray).withdraw!
  end

  def initialize(tray)
    @tray = tray
  end

  def withdraw!
    validate_input!

    unless DissociateTrayFromShelf.call(@tray)
      raise "unable to dissociate tray"
    end

    @tray.items.each do |item|
      DissociateTrayFromItem.call(item)
    end

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
