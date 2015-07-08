FactoryGirl.define do
  factory :tray do
    sequence(:barcode) { |n| AnnexFaker::Tray.barcode_sequence(n) }
    shelf nil
  end

end
