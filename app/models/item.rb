class Item < ActiveRecord::Base
  CONDITIONS = ["COVER-DET",
    "COVER-MISS",
    "COVER-TORN",
    "NEEDS-ENCLS",
    "PAGES-BRITTLE",
    "PAGES-DET",
    "PAGES-MISSING",
    "PAGES-TORN",
    "REDROT",
    "SPINE-DET",
    "UNBOUND",
    "OTHER"]

  enum status: { stocked: 0, unstocked: 1, shipped: 2}

  validates_presence_of :barcode
  validates_presence_of :thickness, on: :update  # Items are going to be programmatically created, humans will be required to enter thickness.
  validates_numericality_of :thickness, on: :update, only_integer: true, greater_than_or_equal_to: 0
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :tray
  belongs_to :bin
  has_one :shelf, through: :tray
  has_many :matches
  has_many :requests, through: :matches
  has_many :batches, through: :matches
  has_many :filled_requests, class_name: "Request", foreign_key: "item_id"

  searchable do
    text :barcode
    text :bib_number
    text :call_number
    text :isbn_issn
    text :title
    text :author
    string :chron
    string :conditions, :multiple => true
    date :initial_ingest
    date :last_ingest
    text :tray_barcode do
      !tray.blank? ? tray.barcode : nil
    end
    text :shelf_barcode do
      !shelf.blank? ? shelf.barcode : nil
    end
    date :requested, :multiple => true do
      requests.map {|request| request.requested}
    end
  end

  def has_correct_prefix
    if !IsItemBarcode.call(barcode)
      errors.add(:barcode, "must not begin with #{IsShelfBarcode::PREFIX}, #{IsTrayBarcode::PREFIX}, or #{IsBinBarcode::PREFIX}")
    end
  end
end
