class AddTrayIssue
  attr_reader :tray, :manual_count, :current_user

  def self.call(tray, manual_count, current_user)
    new(tray, manual_count, current_user).create!
  end

  def initialize(tray, manual_count, current_user)
    @tray = tray
    @manual_count = manual_count
    @current_user = current_user
  end

  def create!
    system_text = "System count = ".to_s + @tray.items.count.to_s
    manual_text = "Manual count = ".to_s + @manual_count.to_s
    message = system_text + '. ' + manual_text + '.'

    issue = Issue.where('barcode = ? AND resolver_id is null',
      @tray.barcode).first
    # If it is a new issue or an issue that hasn't been resolved.
    # In the second case, it may be an issue for a tray that already has a
    # record in the Issues list
    if issue.nil?
      issue = Issue.new(barcode: @tray.barcode, issue_type: "counts_not_match",
        message: message, resolved_at: nil, barcode_type: "tray")
      new_record = issue.new_record?
      issue.user = @current_user
      issue.save!

      if new_record
        ActivityLogger.create_tray_issue(tray: @tray, issue: issue,
          user: current_user)
      end

    # Only update a message for the issue of the same tray that
    # hasn't yet been resolved.
    else
      issue.update!(message: message, user: @current_user)
    end
    issue
  end
end
