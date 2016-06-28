class IssuesForTrayQuery
  attr_reader :relation

  def initialize(barcode:, relation: default_relation)
    @relation = relation.where(barcode: barcode)
  end

  def all_issues
    relation
  end

  def invalid_count_issues?
    if relation.where(issue_type: "incorrect_count", resolver_id: nil).count >= 1
      true
    else
      false
    end
  end

  def issues_by_type(type:)
    !type.nil? ? relation.where(issue_type: type, resolver_id: nil) : []
  end

  private

  def default_relation
    TrayIssue.all
  end
end
