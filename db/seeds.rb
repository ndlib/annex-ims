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
    author: Faker::Name.name)
end
