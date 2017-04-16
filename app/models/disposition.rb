class Disposition < ActiveRecord::Base
  validates_presence_of :code
  validates_inclusion_of :active, :in => [true, false]
end
