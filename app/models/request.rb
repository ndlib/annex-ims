class Request < ActiveRecord::Base
  belongs_to :batch
  belongs_to :item
end
