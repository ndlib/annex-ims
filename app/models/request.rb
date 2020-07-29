# frozen_string_literal: true

class Request < ApplicationRecord
  validates :criteria_type, presence: true
  validates :criteria, presence: true
  validates :rapid, inclusion: { in: [true, false] }
  validates :source, presence: true
  validates :req_type, presence: true

  has_many :matches, dependent: :destroy
  has_many :items, through: :matches
  has_many :batches, through: :matches

  belongs_to :filled_by_item,
             class_name: 'Item',
             foreign_key: 'item_id',
             inverse_of: :item
  belongs_to :filled_in_batch,
             class_name: 'Batch',
             foreign_key: 'batch_id',
             inverse_of: :batch

  enum status: { received: 0, completed: 1 }

  STATUSES = {
    '0' => 'Received',
    '1' => 'Completed'
  }.freeze

  def bin_type
    bt = case source.downcase
         when 'aleph'
           'ALEPH-LOAN'
         when 'illiad'
           if del_type != 'loan'
             'ILL-SCAN'
           else
             'ILL-LOAN'
           end
         else
           'REM-STOCK'
         end

    bt
  end
end
