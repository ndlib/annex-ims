class Request < ActiveRecord::Base
  validates_presence_of :criteria_type
  validates_presence_of :criteria
  validates :rapid, :inclusion => {:in => [true, false]}
  validates_presence_of :source
  validates_presence_of :req_type

  has_many :matches
  has_many :items, through: :matches
  has_many :batches, through: :matches

  belongs_to :filled_by_item, class_name: "Item", foreign_key: "item_id"
  belongs_to :filled_in_batch, class_name: "Batch", foreign_key: "batch_id"

  def bin_type
    if self.source == "aleph"
      bt = "ALEPH-LOAN"
    else
      if self.del_type != "loan"
        bt = "ILL-SCAN"
      else
        bt = "ILL-LOAN"
      end
    end

    return bt
  end
end
