FactoryGirl.define do
  factory :tray_issue do
    user
    sequence(:barcode) { |n| "0000000#{n}" }
    message "TEST"
    issue_type ["incorrect_count", "not_valid_barcode"].sample
  end
end
