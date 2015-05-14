FactoryGirl.define do
  factory :request do
    criteria_type "barcode"
    sequence(:criteria) { |n| "#{n}" }
    requested Faker::Date.between(2.days.ago, Date.today)
    rapid false
    source "aleph"
    req_type "loan"
  end
end
