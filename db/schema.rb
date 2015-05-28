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

ActiveRecord::Schema.define(version: 20150528160030) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: true do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id",                   null: false
    t.boolean  "active",     default: true, null: false
  end

  add_index "batches", ["user_id"], name: "index_batches_on_user_id", using: :btree

  create_table "bins", force: true do |t|
    t.string   "barcode",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "bins", ["barcode"], name: "index_bins_on_barcode", unique: true, using: :btree

  create_table "issues", force: true do |t|
    t.integer  "user_id",     null: false
    t.string   "barcode",     null: false
    t.text     "message",     null: false
    t.integer  "resolver_id"
    t.datetime "resolved_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "issues", ["resolver_id"], name: "index_issues_on_resolver_id", using: :btree
  add_index "issues", ["user_id"], name: "index_issues_on_user_id", using: :btree

  create_table "items", force: true do |t|
    t.string   "barcode",                     null: false
    t.string   "title"
    t.string   "author"
    t.string   "chron"
    t.integer  "thickness"
    t.integer  "tray_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "bib_number"
    t.string   "isbn_issn"
    t.text     "conditions",     default: [],              array: true
    t.string   "call_number"
    t.date     "initial_ingest"
    t.date     "last_ingest"
    t.integer  "bin_id"
    t.integer  "status",         default: 0,  null: false
  end

  add_index "items", ["barcode"], name: "index_items_on_barcode", unique: true, using: :btree
  add_index "items", ["bin_id"], name: "index_items_on_bin_id", using: :btree
  add_index "items", ["tray_id"], name: "index_items_on_tray_id", using: :btree

  create_table "matches", force: true do |t|
    t.integer  "batch_id",   null: false
    t.integer  "item_id",    null: false
    t.integer  "request_id", null: false
    t.string   "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bin_id"
  end

  add_index "matches", ["bin_id"], name: "index_matches_on_bin_id", using: :btree
  add_index "matches", ["item_id", "request_id", "batch_id"], name: "index_matches_on_item_id_and_request_id_and_batch_id", unique: true, using: :btree

  create_table "requests", force: true do |t|
    t.string   "criteria_type", null: false
    t.string   "criteria",      null: false
    t.integer  "item_id"
    t.date     "requested"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "rapid",         null: false
    t.string   "source",        null: false
    t.string   "req_type",      null: false
    t.integer  "batch_id"
    t.string   "trans"
    t.string   "title"
    t.string   "article_title"
    t.string   "author"
    t.string   "description"
    t.string   "barcode"
    t.string   "isbn_issn"
    t.string   "bib_number"
    t.string   "del_type",      null: false
  end

  add_index "requests", ["batch_id"], name: "index_requests_on_batch_id", using: :btree
  add_index "requests", ["item_id"], name: "index_requests_on_item_id", using: :btree
  add_index "requests", ["trans"], name: "index_requests_on_trans", unique: true, using: :btree

  create_table "shelves", force: true do |t|
    t.string   "barcode",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "size"
  end

  add_index "shelves", ["barcode"], name: "index_shelves_on_barcode", unique: true, using: :btree

  create_table "trays", force: true do |t|
    t.string   "barcode",                    null: false
    t.integer  "shelf_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "shelved",    default: false, null: false
  end

  add_index "trays", ["barcode"], name: "index_trays_on_barcode", unique: true, using: :btree
  add_index "trays", ["shelf_id"], name: "index_trays_on_shelf_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",                       null: false
    t.integer  "sign_in_count",      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "batches", "users"
  add_foreign_key "issues", "users", column: "resolver_id"
  add_foreign_key "items", "bins"
  add_foreign_key "items", "trays"
  add_foreign_key "matches", "bins"
  add_foreign_key "matches", "requests"
  add_foreign_key "requests", "batches"
  add_foreign_key "requests", "items"
  add_foreign_key "trays", "shelves"
end
