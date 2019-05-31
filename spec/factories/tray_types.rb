FactoryGirl.define do
  factory :tray_type do
    code "IL"
    trays_per_shelf 16
    unlimited false
    height 7
    capacity 136
    active true
  end

end
