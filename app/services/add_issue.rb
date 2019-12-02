class AddIssue
  attr_reader :user, :item, :issue_type, :message

  def self.call(user:, item:, type:, message: nil)
    new(user: user, item: item, type: type, message: message).add
  end

  def initialize(user:, item:, type:, message:)
    @user = user
    @item = item
    @issue_type = type
    @message = message
  end

  def add
    if valid?
      issue = Issue.find_or_initialize_by(barcode: barcode, issue_type: issue_type, message: message, resolved_at: nil)
      new_record = issue.new_record?
      issue.user = user
      issue.save!
      if new_record
        ActivityLogger.create_issue(item: item, issue: issue, user: user)
      end
      issue
    end
  end

  private

  def barcode
    item.barcode
  end

  def valid?
    IsItemBarcode.call(barcode)
  end
end
