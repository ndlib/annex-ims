class UpdateIngestDate
  attr_reader :item

  def self.call(item)
    new(item).update_ingest!
  end

  def initialize(item)
    @item = item
  end

  def update_ingest!
    validate_input!

    item.initial_ingest ||= Date.today.to_s
    item.last_ingest = Date.today.to_s

    if item.save
      item
    else
      false
    end
  end

    private

  def validate_input!
    if IsObjectItem.call(item)
      true
    else
      raise "object is not an item"
    end
  end
  end
