FactoryBot.define do
  factory :shelf do
    sequence(:barcode) { |n| "SHELF-#{n}" }
  end

end
