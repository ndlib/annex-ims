# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141208175533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "items", force: true do |t|
    t.string   "barcode",    null: false
    t.string   "title"
    t.string   "author"
    t.string   "chron"
    t.integer  "thickness"
    t.integer  "tray_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "items", ["barcode"], name: "index_items_on_barcode", unique: true, using: :btree
  add_index "items", ["tray_id"], name: "index_items_on_tray_id", using: :btree

  create_table "shelves", force: true do |t|
    t.string   "barcode",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shelves", ["barcode"], name: "index_shelves_on_barcode", unique: true, using: :btree

  create_table "trays", force: true do |t|
    t.string   "barcode",    null: false
    t.integer  "shelf_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "trays", ["barcode"], name: "index_trays_on_barcode", unique: true, using: :btree
  add_index "trays", ["shelf_id"], name: "index_trays_on_shelf_id", using: :btree

  add_foreign_key "items", "trays"
  add_foreign_key "trays", "shelves"
end
