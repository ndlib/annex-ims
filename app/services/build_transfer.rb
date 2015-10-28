class BuildTransfer
  def self.call(shelf, user)
    new(shelf, user).build!
  end

  def initialize(shelf, user)
    @shelf = shelf
    @user = user
  end

  def build!
    if self.class.send :retrieve_transfer, @shelf
      self.class.send :retrieve_transfer, @shelf
    else
      transfer = Transfer.new
      transfer.initiated_by = @user
      transfer.shelf = @shelf
      transfer.transfer_type = "ShelfTransfer"
      if transfer.save!
        self.class.send :unshelve_trays, @shelf, @user
      end
      ActivityLogger.create_transfer(shelf: @shelf, transfer: transfer, user: @user)
      Transfer.last
    end
  end

  def self.retrieve_transfer(shelf)
    transfer_records = Transfer.where(shelf: shelf)
    if transfer_records.count >= 1
      transfer_records.take!
    end
  end

  def self.unshelve_trays(shelf, user)
    shelf.trays.each do |tray|
      UnshelveTray.call(tray, user)
    end
  end

  private_class_method :retrieve_transfer
  private_class_method :unshelve_trays
end
