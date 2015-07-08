FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| AnnexFaker::User.username_sequence(n) }
  end

end
