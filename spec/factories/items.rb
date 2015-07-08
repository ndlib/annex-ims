FactoryGirl.define do
  factory :item do
    sequence(:barcode) { |n| AnnexFaker::Item.barcode_sequence(n) }
    title { Faker::Lorem.sentence }
    author { Faker::Name.name }
    chron "Vol 1"
    thickness 1
    tray nil
    bib_number { AnnexFaker::Item.bib_number }
    isbn_issn { AnnexFaker::Item.send([:isbn, :issn].sample) }
    conditions { AnnexFaker::Item.conditions }
    call_number { AnnexFaker::Item.call_number }
    initial_ingest { Date.today - rand(3).days }
    last_ingest Date::today.to_s
    metadata_status "complete"
  end

end
