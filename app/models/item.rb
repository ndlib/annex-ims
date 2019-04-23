class Item < ActiveRecord::Base
  CONDITIONS = [
    "COVER-DET",
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

  METADATA_STATUSES = [
    "pending",
    "complete",
    "not_found",
    "not_for_annex",
    "error",
  ]

  enum status: { stocked: 0, unstocked: 1, shipped: 2, deaccessioned: 9 }

  validates :thickness, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, presence: true, on: :update
  validates :barcode, uniqueness: true, presence: true
  validates :metadata_status, inclusion: METADATA_STATUSES
  validate :has_correct_prefix?

  belongs_to :tray
  belongs_to :bin
  belongs_to :disposition
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
    string :conditions, multiple: true
    date :initial_ingest
    date :last_ingest
    string :tray_barcode do
      !tray.blank? ? tray.barcode : nil
    end
    string :shelf_barcode do
      !shelf.blank? ? shelf.barcode : nil
    end
    string :bin_barcode do
      !bin.blank? ? bin.barcode : nil
    end
    date :requested, multiple: true do
      requests.map &:requested
    end
    string :status
  end

  def has_correct_prefix?
    if !IsItemBarcode.call(barcode)
      errors.add(:barcode, "must not begin with #{IsShelfBarcode::PREFIX}, #{IsTrayBarcode::PREFIX}, or #{IsBinBarcode::PREFIX}")
    end
  end
end
