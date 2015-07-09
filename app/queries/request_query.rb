class RequestQuery
  attr_reader :relation

  def initialize(relation = Request.all)
    @relation = relation
  end

  def remaining_matches
    relation.matches.where("processed IS NULL OR processed NOT IN('skipped', 'completed')")
  end
end
