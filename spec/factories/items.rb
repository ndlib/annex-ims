FactoryGirl.define do
  factory :item do
    sequence(:barcode) { |n| "#{n}" }
    title Faker::Lorem.sentence
    author Faker::Name.name
    chron "Vol 1"
    thickness nil
    tray nil
  end

end
