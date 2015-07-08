FactoryGirl.define do
  factory :bin do
    sequence(:barcode) { |n| AnnexFaker::Bin.barcode_sequence(n) }
  end

end
