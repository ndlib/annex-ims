class AddIssue
  attr_reader :user_id, :barcode, :message

  def self.call(user_id, barcode, message)
    new(user_id, barcode, message).add
  end

  def initialize(user_id, barcode, message)
    @user_id = user_id
    @barcode = barcode
    @message = message
  end

  def add
    if valid?
      issue = Issue.new
      issue.user_id = user_id
      issue.barcode = barcode
      issue.message = message
      issue.save!
    end

  end


  private

    def valid?
      IsItemBarcode.call(barcode)
    end
end
