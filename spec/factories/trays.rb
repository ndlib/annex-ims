FactoryBot.define do
  factory :tray do
    sequence(:barcode) { |n| "TRAY-AL#{n}" }
    shelf nil
  end
end
