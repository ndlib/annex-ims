module UnresolvedIssueQuery
  module_function

  def call(params, relation: default_relation)
    relation.where(resolved_at: nil)
  end

  def default_relation
    Issue.all
  end
  private_class_method :default_relation
end
