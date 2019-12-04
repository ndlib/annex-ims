class ResolveIssue
  attr_reader :item, :issue, :user

  def self.call(item:, issue:, user:)
    new(item: item, issue: issue, user: user).resolve
  end

  def initialize(item:, issue:, user:)
    @item = item
    @issue = issue
    @user = user
  end

  def resolve
    issue.resolver = user
    issue.resolved_at = Time.now
    issue.save!
    ActivityLogger.resolve_issue(item: item, issue: issue, user: user)
  end
end
