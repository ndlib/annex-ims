FactoryGirl.define do
  factory :request do
    criteria_type "barcode"
    sequence(:criteria) { |n| "#{n}" }
    sequence(:barcode) { |n| AnnexFaker::Item.barcode_sequence(n) }
    sequence(:trans) { |n| "aleph_12345#{n}" }
    requested { Date.today - rand(3).days }
    rapid false
    source "aleph"
    del_type "loan"
    req_type "doc_del"
  end
end
