FactoryGirl.define do
  factory :issue do
    user
    sequence(:barcode) { |n| "0000000#{n}" }
    message ["Item not found.", "Unauthorized - Check API Key.", "API Timeout."].sample
  end

end
