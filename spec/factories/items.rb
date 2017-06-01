FactoryGirl.define do
  factory :item do
    sequence(:barcode) { |n| "000012345#{n}" }
    title Faker::Lorem.sentence
    author Faker::Name.name
    chron "Vol 1"
    thickness 1
    tray nil
    bib_number "0037612#{Faker::Number.number(2)}"
    isbn_issn [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}"
    conditions [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq
    call_number "#{('A'..'Z').to_a.sample}#{('A'..'Z').to_a.sample}#{Faker::Number.number(4)}.#{('A'..'Z').to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}"
    initial_ingest Faker::Date.between(2.days.ago, Date.today)
    last_ingest Date::today.to_s
    metadata_status "complete"
    disposition nil
    status 0
  end

end
