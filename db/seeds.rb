# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: "Chicago" }, { name: "Copenhagen" }])
#   Mayor.create(name: "Emanuel", city: cities.first)

# This is just for development purposes. Do not seed the production system with this. We need Items in the system.

def rand_letter
  ("A".."Z").to_a.sample
end

def call_number
  "#{rand_letter}#{rand_letter}#{Faker::Number.number(4)}.#{rand_letter}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}"
end

100.times do |_i|
  Item.create!(
    barcode: Faker::Number.number(14).to_s,
    title: Faker::Lorem.sentence,
    author: Faker::Name.name,
    bib_number: "00#{Faker::Number.number(7)}",
    isbn_issn: [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
    conditions: [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq,
    call_number: call_number,
    initial_ingest: Faker::Date.between(30.days.ago, Date.today),
    last_ingest: Time.now.strftime("%Y-%m-%d"),
    metadata_status: "complete",
    thickness: 1,
  )
end

50.times do |_i|
  barcode = Item.order("RANDOM()").first.barcode
  Request.create!(
    criteria_type: "barcode",
    criteria: barcode,
    barcode: barcode,
    title: "Seed Request #{barcode}",
    requested: Faker::Date.between(30.days.ago, Date.today),
    rapid: false,
    source: "Aleph",
    del_type: "loan",
    req_type: "doc_del",
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

[
  "jhartzle",
  "dwolfe2",
  "rfox2",
  "jkennel",
  "awetheri",
  "jgondron",
  "hbeachey"
].each do |username|
  u = User.where(username: username).first || User.new(username: username)
  u.admin = true
  u.save!
end
