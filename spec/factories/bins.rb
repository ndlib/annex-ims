FactoryBot.define do
  factory :bin do
    sequence(:barcode) { |n| "BIN-ALEPH-LOAN-#{n}" }
  end
end
