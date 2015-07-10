class RequestQuery
  attr_reader :relation

  def initialize(relation = Request.all)
    @relation = relation
  end

  def remaining_matches
    relation.matches.where("processed IS NULL OR processed NOT IN('skipped', 'completed')")
  end

  def find_all_by_id(id_array:)
    relation.where("requests.id IN (?)", id_array)
  end
end
