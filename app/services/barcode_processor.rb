class BarcodeProcessor
  require 'barcode_prefix'
  include BarcodePrefix

  attr_reader :obj, :barcode

  def self.call(obj, barcode)
    new(obj, barcode).associate!
  end

  def initialize(obj, barcode)
    @obj = obj
    @barcode = barcode
  end

  def associate!
    case @obj.class.to_s
    when "Tray"
      if is_shelf(barcode)
        begin
          @shelf = Shelf.where(barcode: barcode).first_or_create!

          @obj.shelf = @shelf
          @obj.save!
p "Got here"
        rescue ActiveRecord::RecordInvalid => e
          return false
        end
      end

      if is_item(barcode)

      end
    else
      raise "don't know how to process barcodes for a #{@obj.class.to_s} yet."
    end

    @obj
  end


  private

    def transaction_log
      # log transaction here
    end

end




