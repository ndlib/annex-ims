module IssuesForTrayQuery
  module_function

  def call(barcode:, relation: default_relation)
    relation.where(barcode: barcode)
  end

  def default_relation
    TrayIssue.all
  end

  private_class_method :default_relation
end
