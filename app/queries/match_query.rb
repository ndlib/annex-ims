class MatchQuery
  attr_reader :relation

  def initialize(relation = Match.all)
    @relation = relation
  end

  def retrieve_set(match)
    set = {}
    relation.where(request: match.request).
      includes(item: { tray: :shelf }).
      order("shelves.barcode").
      order("trays.barcode").
      order("items.title").
      order("items.chron").
      map.
      with_index { |m, i| set[m.item.id] = (i + 1).to_s.to_i.ordinalize }
    set
  end

  def part_of_set?(match)
    relation.where(request: match.request).count > 1
  end
end
