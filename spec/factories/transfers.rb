FactoryGirl.define do
  factory :transfer do
    transfer_type "ShelfTransfer"
    # sequence(:shelf_id) { |n| "#{n}" }
    initiated_by User.new(username: "test")
    sequence(:shelf) { |n|
       Shelf.new(barcode: "SHELF-AL99999999#{n}").save!
       Shelf.last
     }
  end
end
