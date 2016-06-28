module UnresolvedTrayIssueQuery
  module_function

  def call(params, relation: default_relation)
    scope = relation.where(resolved_at: nil)
    barcode = params.fetch(:barcode, nil)
    if barcode.present?
      scope = scope.where(barcode: barcode)
    end
    scope
  end

  def default_relation
    TrayIssue.all
  end
  private_class_method :default_relation
end
