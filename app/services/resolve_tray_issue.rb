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
    issue = Issue.where('barcode = ? AND resolver_id is null',
      @tray.barcode).first

    unless issue.nil?
      issue.resolver = user
      issue.resolved_at = Time.now
      issue.save!
      ActivityLogger.resolve_issue(issue: issue, user: user)
    end
  end
end
