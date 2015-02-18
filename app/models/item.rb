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

  validates_presence_of :barcode
  validates_presence_of :thickness, on: :update  # Items are going to be programmatically created, humans will be required to enter thickness.
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :tray
  has_one :shelf, through: :tray
  has_many :requests

  searchable do
    text :barcode
    text :bib_number
    text :call_number
    text :isbn
    text :issn
    text :title
    text :author
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
      errors.add(:barcode, "must not begin with #{IsShelfBarcode::PREFIX}, #{IsTrayBarcode::PREFIX}, or #{IsToteBarcode::PREFIX}")
    end
  end
end
