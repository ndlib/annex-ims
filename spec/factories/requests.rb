FactoryGirl.define do
  factory :request do
    criteria_type "barcode"
    sequence(:criteria) { |n| "#{n}" }
    sequence(:barcode) { |n| "12345#{n}" }
    sequence(:trans) { |n| "aleph_12345#{n}" }
    requested Faker::Date.between(2.days.ago, Date.today)
    rapid false
    source "aleph"
    del_type "loan"
    req_type "doc_del"
  end
end
