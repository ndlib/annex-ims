# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    name 'MyString'
    fields ['Filled']
    start_date '2020-05-10'
    end_date '2020-05-10'
    activity 'AcceptedItem'
    status 'MyString'
  end
end
