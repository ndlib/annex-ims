json.array!(@tray_types) do |tray_type|
  json.extract! tray_type, :id, :code, :trays_per_shelf, :unlimited, :height, :capacity, :active
  json.url tray_type_url(tray_type, format: :json)
end
