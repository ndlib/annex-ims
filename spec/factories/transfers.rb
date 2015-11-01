FactoryGirl.define do
  factory :transfer do
    transfer_type "ShelfTransfer"
    sequence(:shelf_id) { |n| "#{n}" }
    initiated_by User.new(username: "test")
  end
end
