class DissociateTray
  attr_reader :tray

  def self.call(tray)
    new(tray).dissociate!
  end

  def initialize(tray)
    @tray = tray
  end

  def dissociate!
    tray.shelf = nil

    if tray.save
      transaction_log
      tray
    else
      nil
    end
  end


  private

    def transaction_log
      # log transaction here
    end

end
