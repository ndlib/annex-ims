FactoryBot.define do
  factory :transfer do
    transfer_type "ShelfTransfer"
    # sequence(:shelf_id) { |n| "#{n}" }
    sequence(:initiated_by) do |n|
      User.new(username: "test#{n}").save!
      User.last
    end
    sequence(:shelf) do |n|
      Shelf.new(barcode: "SHELF-AL99999999#{n}").save!
      Shelf.last
    end
  end
end
