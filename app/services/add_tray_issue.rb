class AddTrayIssue
  attr_reader :user, :tray, :issue_type, :message

  def self.call(user:, tray:, type:, message: nil)
    new(user: user, tray: tray, type: type, message: message).add
  end

  def initialize(user:, tray:, type:, message:)
    @user = user
    @tray = tray
    @issue_type = type
    @message = message
  end

  def add
    if valid?
      issue = TrayIssue.find_or_initialize_by(barcode: barcode, issue_type: issue_type, message: message, resolved_at: nil)
      new_record = issue.new_record?
      issue.user = user
      issue.save!
      if new_record
        ActivityLogger.create_tray_issue(tray: tray, issue: issue, user: user)
      end
      issue
    end
  end

  private

  def barcode
    tray.barcode
  end

  def valid?
    IsTrayBarcode.call(barcode)
  end
end
