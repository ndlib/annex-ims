class AcceptMatch
  attr_reader :match

  def self.call(match)
    new(match).accept!
  end

  def initialize(match)
    @match = match
  end

  def accept!
    @match.processed = "accepted"
    @match.save!

    @match.request.filled_by_item = @match.item
    @match.request.filled_in_batch = @match.batch
    @match.request.save!

    @match.batch.unprocessed_matches_for_request(@match.request).each do |un|
      un.processed = "skipped"
      un.save!
    end
  end

end
