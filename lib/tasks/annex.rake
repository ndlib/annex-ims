namespace :annex do
  desc "Retrieves active requests from the API and creates or updates local request records"
  task get_active_requests: :environment do
    logger = Logger.new(STDOUT)
    requests = GetRequests.call
    message = I18n.t("requests.synchronized", count: requests.count)
    logger.info("[annex:get_active_requests] #{message}")
  end

  desc "Destroys items created by inaccurate barcode scans or items that were not meant for annex."
  task destroy_invalid_items: :environment do
    require 'csv'
    require Rails.root.join("lib", "tasks", "services", "destroy_invalid_items.rb").to_s

    logger = Logger.new(STDOUT)

    system_user = OpenStruct.new({ user_id: nil, username: "system" })
    results = Lib::Tasks::Services::DestroyInvalidItems.call(user: system_user)
    timestamp = (DateTime.now.to_f * 1000).to_i
    item_attrs = Item.new.attributes.map { |k, v| k }

    if results[:destroyed].present?
      destroyed_file = CSV.open("destroyed_items_#{timestamp}.csv", "w")
      destroyed_file << item_attrs
      results[:destroyed].each do |item|
        destroyed_file << item_attrs.map { |k| item[k] }
      end
      destroyed_file.close
      print "Wrote destroyed items to #{destroyed_file.path}\n"
    else
      print "No items were destroyed.\n"
    end

    if results[:failed].present?
      failed_file = CSV.open("failed_items_#{timestamp}.csv", "w")
      failed_file << item_attrs
      results[:failed].each do |item|
        failed_file << item_attrs.map { |k| item[k] }
      end
      failed_file.close
      print "Wrote failed items to #{failed_file.path}\n"
    end
  end

  # Matches associated with AIMS-331
  def broken_matches
    Match.
      where.not(bin_id: nil).
      where('"matches"."processed" != \'completed\'').
      joins(:request).where(requests: { del_type: "scan" }).
      joins(:item).where('"items"."bin_id" IS NULL OR "items"."bin_id" != "matches"."bin_id"').
      order(:bin_id)
  end

  # Due to bug AIMS-331, some matches for scan requests and their related items entered
  # into an inconsistent state where the match remained as unprocessed in a bin but the
  # item was restocked and dissociated from the bin. This task will dump the associated
  # matches that need to be corrected to files as follows:
  #
  # Raw match data that was affected will be output to fixed_matches.txt
  # Formatted data similar to the "Process Batch" view will be output to fixed_matches_view.txt
  #
  desc "Dump matches associated with AIMS-331"
  task dump_aims331_matches: :environment do

    view_file = File.open("fixed_matches_view.csv", "w")
    match_file = File.open("fixed_matches.txt", "w")

    view_file << "\"Bin\",\"User\",\"Barcode\",\"Transaction\",\"Title\",\"Author\"\n"
    broken_matches.each do |match|
      view_file << "\"#{match.bin_id}\",\"#{match.batch.user.username}\",\"#{match.item.barcode}\",\"#{match.request.trans}\",\"#{match.item.title}\",\"#{match.item.author}\""
      view_file << "\n"
      match_file << match.attributes << "\n"
    end
    view_file.close
    match_file.close
  end

  # Due to bug AIMS-331, some matches for scan requests and their related items entered
  # into an inconsistent state where the match remained as unprocessed in a bin but the
  # item was restocked and dissociated from the bin. This is a one time fix for any data
  # remaining in that state. It will do the following:
  #
  # For each match in this state:
  #   Log a scan activity for the item/request
  #   Change the match status to completed
  #   Dissociate the match and bin
  #
  desc "Fix matches associated with AIMS-331"
  task fix_aims331_matches: :environment do

    broken_matches.each do |match|
      data = { item: match.item.attributes, request: match.request.attributes, user: nil }
      last_time_in_bin = ActivityLog.where(action: "DissociatedItemAndBin").where("data->'item'->>'id' = '#{match.item.id}'").where("data->'bin'->>'id' = '#{match.bin.id}'").maximum(:created_at)
      ActiveRecord::Base.transaction do
        ActivityLog.create!(action: "ScannedItem", data: data, action_timestamp: last_time_in_bin, username: "system", user_id: "system")
        match.update!(bin: nil, processed: "completed")
      end
    end
  end

  desc "Populate default tray types"
  task populate_tray_types: :environment do

    ah = { trays_per_shelf: 16, height: 8, capacity: 136 }
    al = { trays_per_shelf: 16, height: 7, capacity: 136 }
    bh = { trays_per_shelf: 14, height: 10, capacity: 136 }
    bl = { trays_per_shelf: 14, height: 8, capacity: 136 }
    ch = { trays_per_shelf: 12, height: 12, capacity: 136 }
    cl = { trays_per_shelf: 12, height: 10, capacity: 136 }
    dh = { trays_per_shelf: 10, height: 14, capacity: 136 }
    dl = { trays_per_shelf: 10, height: 12, capacity: 136 }
    eh = { trays_per_shelf: 12, height: 16, capacity: 104 }
    el = { trays_per_shelf: 12, height: 14, capacity: 104 }
    s = { trays_per_shelf: 1, height: 1, capacity: nil, unlimited: true }
    TrayType.create_with(ah).find_or_create_by(code: "AH")
    TrayType.create_with(al).find_or_create_by(code: "AL")
    TrayType.create_with(bh).find_or_create_by(code: "BH")
    TrayType.create_with(bl).find_or_create_by(code: "BL")
    TrayType.create_with(ch).find_or_create_by(code: "CH")
    TrayType.create_with(cl).find_or_create_by(code: "CL")
    TrayType.create_with(dh).find_or_create_by(code: "DH")
    TrayType.create_with(dl).find_or_create_by(code: "DL")
    TrayType.create_with(eh).find_or_create_by(code: "EH")
    TrayType.create_with(el).find_or_create_by(code: "EL")
    TrayType.create_with(s).find_or_create_by(code: "SHELF")
  end

  desc "Assign tray types to trays"
  task assign_tray_types: :environment do

    Tray.all.each do |tray|
      tray.save
    end
  end
end
