FactoryBot.define do
  factory :issue do
    user
    sequence(:barcode) { |n| "0000000#{n}" }
    issue_type ["not_for_annex", "not_found", "not_valid_barcode"].sample
  end
end
