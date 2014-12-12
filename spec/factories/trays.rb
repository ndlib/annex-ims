FactoryGirl.define do
  factory :tray do
    sequence(:barcode) { |n| "TRAY-A#{n}" }
    shelf nil
  end

end
