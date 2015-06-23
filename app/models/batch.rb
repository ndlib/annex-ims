class Batch < ActiveRecord::Base
  has_many :matches
  has_many :requests, through: :matches
  has_many :items, through: :matches
  belongs_to :user

  validates_presence_of :user_id

  def skipped_matches
    self.matches.where("matches.processed = 'skipped'")
  end

  def unprocessed_matches_for_request(request)
    self.matches.where("matches.processed IS NULL").where(request: request.id)
  end

  def current_match
    self.matches.where("matches.processed IS NULL").joins(item: {tray: :shelf}).order("shelves.barcode").order("trays.barcode").order("items.title").order("items.chron").first
  end
end
