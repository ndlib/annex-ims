# The system currently performs an optimistic creation of an item
# using whatever it's given as a barcode. This service was
# specifically added to clean up invalid items created due to things
# like receiving junk barcodes from the scanner.
module Lib
  module Tasks
    module Services
      class DestroyInvalidItems
        attr_reader :user

        def self.call(user:)
          new(user: user).destroy
        end

        def initialize(user:)
          @user = user
        end

        def destroy
          items = Item.
                  where(tray_id: nil).
                  where("metadata_updated_at < ?", 1.hour.ago).
                  where(metadata_status: ["not_found", "not_for_annex"])
          destroyed = []
          failures = []
          items.each do |item|
            success = DestroyItem.call(item, user)
            if success
              destroyed << item
            else
              failures << item
            end
          end
          { destroyed: destroyed, failed: failures }
        end
      end
    end
  end
end
