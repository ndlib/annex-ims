class AddIssue
  attr_reader :user_id, :item, :issue_type

  def self.call(user_id:, item:, type:)
    new(user_id: user_id, item: item, type: type).add
  end

  def initialize(user_id:, item:, type:)
    @user_id = user_id
    @item = item
    @issue_type = type
  end

  def add
    if valid?
      issue = Issue.find_or_initialize_by(barcode: barcode, issue_type: issue_type, resolved_at: nil)
      issue.user_id = user_id
      if issue.new_record?
        ActivityLogger.create_issue(item: item, issue: issue)
      end
      issue.save!
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
