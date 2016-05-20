class ResolveTrayIssue
  attr_reader :tray, :user

  def self.call(tray, user)
    new(tray, user).resolve!
  end

  def initialize(tray, user)
    @tray = tray
    @user = user
  end

  def resolve!
    issue = Issue.find_by_barcode(@tray.barcode)

    unless issue.nil?
      issue.resolver = user
      issue.resolved_at = Time.now
      issue.save!
      ActivityLogger.resolve_issue(issue: issue, user: user)
    end
  end
end
