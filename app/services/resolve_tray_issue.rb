class ResolveTrayIssue
  attr_reader :issue, :user

  def self.call(issue:, user:)
    new(issue: issue, user: user).resolve
  end

  def initialize(issue:, user:)
    @issue = issue
    @user = user
  end

  def resolve
    issue.resolver = user
    issue.resolved_at = Time.now
    issue.save!
    ActivityLogger.resolve_tray_issue(issue: issue, user: user)
  end
end
