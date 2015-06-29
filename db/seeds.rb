# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# This is just for development purposes. Do not seed the production system with this. We need Items in the system.

100.times do |i|
  Item.create(barcode: Faker::Number.number(14),
    title: Faker::Lorem.sentence,
    author: Faker::Name.name,
    bib_number: "0037612#{Faker::Number.number(2)}",
    isbn_issn: [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
    conditions: [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq,
    call_number: "#{('A'..'Z').to_a.sample}#{('A'..'Z').to_a.sample}#{Faker::Number.number(4)}.#{('A'..'Z').to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}",
    initial_ingest: Faker::Date.between(30.days.ago, Date.today),
    last_ingest: Time.now.strftime("%Y-%m-%d"),
    thickness: 1)
end

50.times do |i|
  Request.create(criteria_type: "barcode",
    criteria: Item.order("RANDOM()").first.barcode,
    requested: Faker::Date.between(30.days.ago, Date.today),
    rapid: false,
    source: "Aleph",
    del_type: "loan",
    req_type: "doc_del")
end
