FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "hallett#{n}" }
    last_activity_at { Time.now }
  end
end
