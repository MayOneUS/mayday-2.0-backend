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

ActiveRecord::Schema.define(version: 20150207021537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns_districts", id: false, force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "district_id", null: false
  end

  add_index "campaigns_districts", ["campaign_id", "district_id"], name: "index_campaigns_districts_on_campaign_id_and_district_id", using: :btree
  add_index "campaigns_districts", ["district_id", "campaign_id"], name: "index_campaigns_districts_on_district_id_and_campaign_id", using: :btree

  create_table "districts", force: :cascade do |t|
    t.string   "district"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "districts", ["state_id"], name: "index_districts_on_state_id", using: :btree

  create_table "districts_zip_codes", id: false, force: :cascade do |t|
    t.integer "district_id", null: false
    t.integer "zip_code_id", null: false
  end

  add_index "districts_zip_codes", ["district_id", "zip_code_id"], name: "index_districts_zip_codes_on_district_id_and_zip_code_id", using: :btree
  add_index "districts_zip_codes", ["zip_code_id", "district_id"], name: "index_districts_zip_codes_on_zip_code_id_and_district_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.string   "abbrev"
    t.boolean  "single_district"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "zip_codes", force: :cascade do |t|
    t.string   "zip_code"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "district_count"
    t.boolean  "on_house_gov"
    t.datetime "last_checked"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "zip_codes", ["state_id"], name: "index_zip_codes_on_state_id", using: :btree
  add_index "zip_codes", ["zip_code"], name: "index_zip_codes_on_zip_code", unique: true, using: :btree

  add_foreign_key "districts", "states"
  add_foreign_key "zip_codes", "states"
end
