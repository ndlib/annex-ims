class DissociateTrayFromShelf
  attr_reader :tray

  def self.call(tray)
    new(tray).dissociate!
  end

  def initialize(tray)
    @tray = tray
  end

  def dissociate!
    tray.shelf = nil

    unless UnshelveTray.call(@tray)
      raise "unable to unshelve tray"
    end

    if tray.save
      transaction_log
      tray
    else
      false
    end
  end


  private

    def transaction_log
      # log transaction here
    end

end
