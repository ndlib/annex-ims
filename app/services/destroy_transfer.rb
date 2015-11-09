class DestroyTransfer
  def self.call(transfer, user)
    new(transfer, user).destroy
  end

  def initialize(transfer, user)
    @transfer = transfer
    @shelf = transfer.shelf
    @user = user
  end

  def destroy
    ActiveRecord::Base.transaction do
      @transfer.destroy!
      self.class.send :shelve_trays, @shelf, @user
      ActivityLogger.destroy_transfer(shelf: @shelf, transfer: @transfer, user: @user)
      "success"
    end
  rescue StandardError => e
    e.message
  end

  def self.shelve_trays(shelf, user)
    shelf.trays.each do |tray|
      ShelveTray.call(tray, user)
    end
  end

  private_class_method :shelve_trays
end
