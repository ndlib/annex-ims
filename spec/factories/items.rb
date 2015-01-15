FactoryGirl.define do
  factory :item do
    sequence(:barcode) { |n| "#{n}" }
    title Faker::Lorem.sentence
    author Faker::Name.name
    chron "Vol 1"
    thickness nil
    tray nil
    bib_number "0037612#{Faker::Number.number(2)}"
    isbn Faker::Code.isbn
    issn "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}"
    conditions [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq
  end

end
