class Simulator
  class BulkLogger
    attr_reader :count, :simulator, :item_attributes, :tray_attributes, :log_attributes
    attr_accessor :current_count

    def self.call(count: 1_000)
      new(count: count).bulk_create!
    end

    def initialize(count: 1_000)
      @count = count
      @current_count = 0
      @simulator = Simulator.new
      @item_attributes = build_item_attributes
      @tray_attributes = build_tray_attributes
      @log_attributes = build_log_attributes
    end

    def bulk_create!
      while current_count < count do
        create_log!
      end
    end

    def create_log!
      data = {item: item_attributes, tray: tray_attributes}.to_json
      log_attributes[:data] = data
      sql = "INSERT INTO activity_logs"
      increment_count
      sql
    end

    private

    def increment_count
      current_count += 1
      item_attributes[:id] += 1
      item_attributes[:barcode] = AnnexFaker::Item.barcode
      if current_count % 10 == 0
        tray_attributes[:id] += 1
        tray_attributes[:barcode] = AnnexFaker::Tray.barcode
      end
    end

    def build_item_attributes
      object = simulator.create_item
      object.attributes.clone.tap
    end

    def build_tray_attributes
      object = simulator.create_tray
      object.attributes.clone.tap
    end

    def build_log_attributes
      ::ActivityLog.first
      object.attributes.clone.tap do |hash|
        hash.delete(:id)
        hash.delete(:data)
      end
    end
  end
end
