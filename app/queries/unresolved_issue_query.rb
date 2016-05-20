module UnresolvedIssueQuery
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
    Issue.all
  end

  def call_items(params, relation: items_relation)
    scope = relation.where(resolved_at: nil)
    barcode = params.fetch(:barcode, nil)
    if barcode.present?
      scope = scope.where(barcode: barcode)
    end
    scope
  end

  def items_relation
    Issue.where("barcode_type = 'item'")
  end

  def call_trays(params, relation: trays_relation)
    scope = relation.where(resolved_at: nil)
    barcode = params.fetch(:barcode, nil)
    if barcode.present?
      scope = scope.where(barcode: barcode)
    end
    scope
  end

  def trays_relation
    Issue.where("barcode_type = 'tray'")
  end

  private_class_method :default_relation
end
