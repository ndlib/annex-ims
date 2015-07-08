# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: "Chicago" }, { name: "Copenhagen" }])
#   Mayor.create(name: "Emanuel", city: cities.first)

# This is just for development purposes. Do not seed the production system with this. We need Items in the system.

simulator = Simulator.new

100.times do
  simulator.create_item
end

50.times do |i|
  barcode = Item.order("RANDOM()").first.barcode
  simulator.create_request(
    criteria_type: "barcode",
    criteria: barcode,
    barcode: barcode,
    del_type: "loan",
  )
end

50.times do
  barcode = Item.order("RANDOM()").first.barcode
  Issue.create!(
    user_id: 1,
    barcode: barcode,
    issue_type: "not_found"
  )
end

50.times do
  barcode = Item.order("RANDOM()").first.barcode
  Issue.create!(
    user_id: 1,
    barcode: barcode,
    issue_type: "not_for_annex"
  )
end
