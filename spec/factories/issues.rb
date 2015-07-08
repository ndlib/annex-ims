FactoryGirl.define do
  factory :issue do
    user
    sequence(:barcode) { |n| AnnexFaker::Item.barcode_sequence(n) }
    issue_type { ["not_for_annex", "not_found"].sample }
  end

end
