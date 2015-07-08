class IsPartOfSet
  # Determine whether a matched item for a request is part of a set

  def self.call(match)
    new(match).part_of_set?
  end

  def initialize(match)
    @match = match
    @request = match.request
  end

  def part_of_set?
    Match.where(request: @request).count > 1    
  end
end