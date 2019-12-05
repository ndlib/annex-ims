class WithdrawTray
  attr_reader :tray, :user

  def self.call(tray, user)
    new(tray, user).withdraw!
  end

  def initialize(tray, user)
    @tray = tray
    @user = user
  end

  def withdraw!
    validate_input!

    unless DissociateTrayFromShelf.call(@tray, @user)
      raise "unable to dissociate tray"
    end

    @tray.items.each do |item|
      DissociateTrayFromItem.call(item, @user)
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
