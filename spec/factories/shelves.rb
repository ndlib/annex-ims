FactoryGirl.define do
  factory :shelf do
    sequence(:barcode) { |n| AnnexFaker::Shelf.barcode_sequence(n) }
  end

end
