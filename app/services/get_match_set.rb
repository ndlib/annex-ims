class GetMatchSet
  # Retrieve set of matches based on a request

  def self.call(match)
    new(match).get_set
  end

  def initialize(match)
    @match = match
    @request = match.request
  end

  def get_set
    set = {}
    Match.where(request: @request).
      includes(item: { tray: :shelf }).
      order("shelves.barcode").
      order("trays.barcode").
      order("items.title").
      order("items.chron").
      map.
      with_index { |m,i| set[m.item.id] = "#{i + 1}".to_i.ordinalize }
    set
  end
end
