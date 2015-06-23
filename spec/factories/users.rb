FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "hallett#{n}" }
  end

end
