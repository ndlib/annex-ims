class Simulator
  class BulkLogger
    STATEMENT_NAME = "activity_log_bulk_insert".freeze

    attr_reader :count, :show_progress
    attr_accessor :current_count

    def self.call(count: 1_000, show_progress: false)
      new(count: count, show_progress: show_progress).bulk_create!
    end

    def initialize(count: 1_000, show_progress: false)
      @count = count
      @show_progress = show_progress
      self.current_count = 0
    end

    def bulk_create!
      while current_count < count do
        set_progress
        create_log!
      end
      set_progress_complete
      self
    end

    def create_log!
      data = {item: item_attributes, tray: tray_attributes}.to_json
      log_attributes[:data] = data
      result = insert_log
      increment_count
      result
    end

    def simulator
      @simulator ||= Simulator.new
    end

    def item_attributes
      @item_attributes ||= build_item_attributes
    end

    def tray_attributes
      @tray_attributes ||= build_tray_attributes
    end

    def log_attributes
      @log_attributes ||= build_log_attributes
    end

    private

    def insert_log
      setup_prepared_insert
      values = log_keys.map { |key| log_attributes.fetch(key) }
      raw_connection.exec_prepared(STATEMENT_NAME, values)
    end

    def setup_prepared_insert
      unless @setup_prepared_insert
        if !prepared_statement_exists?
          raw_connection.prepare(STATEMENT_NAME, base_insert_sql)
        end
        @setup_prepared_insert = true
      end
      @setup_prepared_insert
    end

    def prepared_statement_exists?
      result = connection.execute("SELECT * FROM pg_prepared_statements WHERE name = '#{STATEMENT_NAME}'")
      result.count > 0
    end

    def connection
      ActiveRecord::Base.connection
    end

    def raw_connection
      connection.raw_connection
    end

    def base_insert_sql
      @base_insert_sql ||= "INSERT INTO activity_logs (#{log_columns}) VALUES (#{log_value_placeholders})"
    end

    def log_keys
      @log_keys ||= log_attributes.keys
    end

    def log_columns
      @log_columns ||= log_keys.join(", ")
    end

    def log_value_placeholders
      @log_value_placeholders ||= ((1..log_keys.count).map{ |i| "$#{i}" }).join(", ")
    end

    def increment_count
      self.current_count += 1
      item_attributes[:id] += 1
      item_attributes[:barcode] = AnnexFaker::Item.barcode
      if current_count % 10 == 0
        tray_attributes[:id] += 1
        tray_attributes[:barcode] = AnnexFaker::Tray.barcode
      end
    end

    def build_item_attributes
      object = simulator.create_item
      object.attributes.with_indifferent_access.tap do |hash|
        hash[:created_at] = hash[:created_at].to_s(:db)
        hash[:updated_at] = hash[:updated_at].to_s(:db)
        hash[:initial_ingest] = hash[:initial_ingest].to_s(:db)
        hash[:last_ingest] = hash[:last_ingest].to_s(:db)
      end
    end

    def build_tray_attributes
      object = simulator.create_tray
      object.attributes.with_indifferent_access.tap do |hash|
        hash[:created_at] = hash[:created_at].to_s(:db)
        hash[:updated_at] = hash[:updated_at].to_s(:db)
      end
    end

    def build_log_attributes
      object = ActivityLog.new()
      object.attributes.with_indifferent_access.tap do |hash|
        hash.delete(:id)
        hash[:action] = "BulkInsert"
        now = Time.now.to_s(:db)
        hash[:action_timestamp] = now
        hash[:created_at] = now
        hash[:updated_at] = now
      end
    end

    def set_progress
      if show_progress
        $stdout.write "\r#{progress_message}"
        $stdout.flush
      end
    end

    def set_progress_complete
      if show_progress
        set_progress
        $stdout.write("\n")
      end
    end

    def progress_message
      percent = (current_count.to_f / count * 100).floor
      "Bulk inserting activity logs: #{percent}% #{current_count}/#{count}"
    end
  end
end
