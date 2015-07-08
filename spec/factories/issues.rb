FactoryGirl.define do
  factory :issue do
    user
    sequence(:barcode) { |n| "0000000#{n}" }
    issue_type { ["not_for_annex", "not_found"].sample }
  end

end
