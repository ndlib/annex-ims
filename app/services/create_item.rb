class CreateItem
  attr_reader :tray, :barcode, :current_user_id, :thickness, :set_aside_flag

  def self.call(tray, barcode, current_user_id, thickness, set_aside_flag)
    new(tray, barcode, current_user_id, thickness, set_aside_flag).create!
  end

  def initialize(tray, barcode, current_user_id, thickness, set_aside_flag)
    @tray = tray
    @barcode = barcode
    @current_user_id = current_user_id
    @thickness = thickness
    @set_aside_flag = set_aside_flag
  end

  def create!
    begin
      item = GetItemFromBarcode.call(barcode: barcode, user_id: current_user_id)
    rescue StandardError
      return "errors.barcode_not_found"
    end

    # Only if the item barcode wasn't found in the database and was set aside by the system
    if item.nil? && set_aside_flag.nil?
      return "errors.barcode_not_found"
    # When the item barcode wasn't found in the database and was set aside by the user
    elsif !set_aside_flag.nil?
      issue = Issue.find_by(barcode: barcode)
      issue.issue_type = "not_valid_barcode"
      issue.save!
      return
    end

    already = false

    if !item.tray.nil?
      if item.tray != tray
        return "Item #{barcode} is already assigned to #{item.tray.barcode}."
      else
        already = true
      end
    end

    begin
      AssociateTrayWithItemBarcode.call(current_user_id, tray, barcode, thickness)
      if already
        return "Item #{barcode} already assigned to #{tray.barcode}. Record updated."
      else
        return "Item #{barcode} stocked in #{tray.barcode}."
      end
    rescue StandardError => e
      return e
    end
  end
end
