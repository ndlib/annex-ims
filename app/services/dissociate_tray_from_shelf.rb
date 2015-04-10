class DissociateTrayFromShelf
  attr_reader :tray

  def self.call(tray)
    new(tray).dissociate!
  end

  def initialize(tray)
    @tray = tray
  end

  def dissociate!
    shelf = tray.shelf
    tray.shelf = nil

    unless UnshelveTray.call(@tray)
      raise "unable to unshelve tray"
    end

    if tray.save
      transaction_log
      result = tray
    else
      result = false
    end

    if shelf.trays.count == 0
      shelf.size = nil
      shelf.save
    end

    return result
  end


  private

    def transaction_log
      # log transaction here
    end

end
