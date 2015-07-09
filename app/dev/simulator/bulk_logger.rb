class Simulator
  class BulkLogger
    STATEMENT_NAME = "activity_log_bulk_insert".freeze

    attr_reader :count, :show_progress
    attr_accessor :current_count

    def self.call(count: 1_000, show_progress: false)
      new(count: count, show_progress: show_progress).bulk_create!
    end

    def self.threaded(thread_count: 4, count: 1_000, show_progress: false)
      master_logger = new(count: count, show_progress: show_progress)
      master_logger.prepare_threaded
      threads = []
      loggers = []
      mutex = Mutex.new
      thread_count.times do |i|
        threads << Thread.new do
          logger = new(count: (count / thread_count), show_progress: false)
          mutex.synchronize do
            loggers << logger
          end
          logger.bulk_create!
        end
      end
      sleep(0.2)
      spy = Thread.new do
        loop do
          master_logger.current_count = loggers.map(&:current_count).sum
          master_logger.set_progress
          sleep(0.05)
        end
      end
      threads.each { |t| t.join }
      spy.kill
      master_logger.current_count = loggers.map(&:current_count).sum
      master_logger.set_progress_complete
    ensure
      threads.each { |t| t.kill }
      spy.kill
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

    def prepare_threaded
      setup_prepared_insert
      setup_create_item
      setup_stock_item
      setup_shelve_tray
    end

    def create_log!
      chance = rand(100)
      if chance < 45
        setup_create_item
      elsif chance < 90
        setup_stock_item
      else
        setup_shelve_tray
      end
      result = insert_log
      self.current_count += 1
      result
    end

    def setup_create_item
      set_log_action("CreatedItem")
      set_log_data(
        item: item_attributes,
      )
    end

    def setup_stock_item
      set_log_action("StockedItem")
      set_log_data(
        item: item_attributes,
        tray: tray_attributes,
      )
    end

    def setup_shelve_tray
      set_log_action("ShelvedTray")
      set_log_data(
        tray: tray_attributes,
        shelf: shelf_attributes
      )
    end

    def simulator
      @simulator ||= Simulator.new
    end

    def item_attributes
      @item_attributes ||= build_item_attributes
      @item_attributes.tap do |hash|
        if rand(3) == 0
          hash[:id] += 1
          hash[:barcode] = AnnexFaker::Item.barcode
        end
      end
    end

    def tray_attributes
      @tray_attributes ||= build_tray_attributes
      @tray_attributes.tap do |hash|
        if rand(10) == 0
          hash[:id] += 1
          hash[:barcode] = AnnexFaker::Tray.barcode
        end
      end
    end

    def shelf_attributes
      @shelf_attributes ||= build_shelf_attributes
      @shelf_attributes.tap do |hash|
        if rand(10) == 0
          hash[:id] += 1
          hash[:barcode] = AnnexFaker::Shelf.barcode
        end
      end
    end

    def log_attributes
      @log_attributes ||= build_log_attributes
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

    private

    def set_log_action(value)
      log_attributes[:action] = value
    end

    def set_log_data(value)
      log_attributes[:data] = value.to_json
    end

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

    def build_item_attributes
      object = Item.take || simulator.create_item
      object.attributes.with_indifferent_access.tap do |hash|
        hash[:created_at] = hash[:created_at].to_s(:db)
        hash[:updated_at] = hash[:updated_at].to_s(:db)
        hash[:initial_ingest] = (hash[:initial_ingest] || Time.now).to_s(:db)
        hash[:last_ingest] = (hash[:last_ingest] || Time.now).to_s(:db)
      end
    end

    def build_tray_attributes
      object = Tray.take || simulator.create_tray
      object.attributes.with_indifferent_access.tap do |hash|
        hash[:created_at] = hash[:created_at].to_s(:db)
        hash[:updated_at] = hash[:updated_at].to_s(:db)
      end
    end

    def build_shelf_attributes
      object = Shelf.take || simulator.create_shelf
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

    def progress_message
      percent = (current_count.to_f / count * 100).floor
      "Bulk inserting activity logs: #{percent}% #{current_count}/#{count}"
    end
  end
end
