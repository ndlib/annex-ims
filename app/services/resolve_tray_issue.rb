class ResolveTrayIssue
  attr_reader :issue, :user

  def self.call(tray:, issue:, user:)
    new(tray: tray, issue: issue, user: user).resolve
  end

  def initialize(tray:, issue:, user:)
    @tray = tray
    @issue = issue
    @user = user
  end

  def resolve
    issue.resolver = user
    issue.resolved_at = Time.zone.now
    issue.save!
    ActivityLogger.resolve_tray_issue(tray: @tray, issue: issue, user: user)
  end
end
