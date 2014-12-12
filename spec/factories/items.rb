FactoryGirl.define do
  factory :item do
    sequence(:barcode) { |n| "#{n}" }
    title "Title"
    author "Firstname Lastname"
    chron "Vol 1"
    width 1
    tray nil
  end

end
