class DissociateTrayFromShelf
  attr_reader :tray, :user

  def self.call(tray, user)
    new(tray, user).dissociate!
  end

  def initialize(tray, user)
    @tray = tray
    @user = user
  end

  def dissociate!
    unless UnshelveTray.call(tray, user)
      raise "unable to unshelve tray"
    end

    shelf = tray.shelf
    tray.shelf = nil

    if tray.save
      ActivityLogger.dissociate_tray_and_shelf(tray: tray, shelf: shelf, user: user)
      result = tray
    else
      result = false
    end

    if shelf.trays.count == 0
      shelf.size = nil
      shelf.save
    end

    result
  end

  private

  def transaction_log
    # log transaction here
  end
end
