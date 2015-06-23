class ResolveIssue
  attr_reader :user_id, :issue_id

  def self.call(user_id, issue_id)
    new(user_id, issue_id).resolve
  end

  def initialize(user_id, issue_id)
    @user_id = user_id
    @issue_id = issue_id
  end

  def resolve
    issue = Issue.find(@issue_id)
    issue.resolver_id = @user_id
    issue.resolved_at = Time.now
    issue.save!
  end

end
