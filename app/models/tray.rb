class Tray < ActiveRecord::Base
  belongs_to :shelf
  has_many :items
end
