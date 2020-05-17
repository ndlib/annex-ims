# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    name 'MyString'
    fields 'MyText'
    start_date '2020-05-10'
    end_date '2020-05-10'
    activity 'MyString'
    status 'MyString'
  end
end
