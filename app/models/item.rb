class Item < ActiveRecord::Base
  CONDITIONS = ["COVER-MISS",
    "COVER-TORN",
    "COVER-DET",
    "SPINE-DET",
    "PAGES-DET",
    "PAGES-TORN",
    "PAGES-MISSING",
    "NEEDS-ENCLS",
    "PAGES-BRITTLE",
    "REDROT",
    "UNBOUND",
    "OTHER"]

  CRITERIA_TYPES = [["Barcode", "barcode"],
    ["Bib Number", "bib_number"],
    ["Call Number", "call_number"],
    ["ISBN", "isbn"],
    ["ISSN", "issn"],
    ["Title", "title"],
    ["Author", "author"],
    ["Tray", "tray"],
    ["Shelf", "shelf"]]

  validates_presence_of :barcode
  validates_presence_of :thickness, on: :update  # Items are going to be programmatically created, humans will be required to enter thickness.
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :tray
  has_one :shelf, through: :tray

  def has_correct_prefix
    if !IsItemBarcode.call(barcode)
      errors.add(:barcode, "must not begin with #{IsShelfBarcode::PREFIX}, #{IsTrayBarcode::PREFIX}, or #{IsToteBarcode::PREFIX}")
    end
  end
end
