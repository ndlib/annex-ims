class Disposition < ActiveRecord::Base
  validates_presence_of :name
  validates_inclusion_of :active, :in => [true, false]
end
