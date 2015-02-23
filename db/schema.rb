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

ActiveRecord::Schema.define(version: 20150221093349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
  add_index "districts_zip_codes", ["zip_code_id", "district_id"], name: "index_districts_zip_codes_on_zip_code_id_and_district_id", unique: true, using: :btree

  create_table "legislators", force: :cascade do |t|
    t.string   "bioguide_id",         null: false
    t.date     "birthday"
    t.string   "chamber"
    t.integer  "district_id"
    t.string   "facebook_id"
    t.string   "first_name"
    t.string   "gender"
    t.boolean  "in_office"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "name_suffix"
    t.string   "nickname"
    t.string   "office"
    t.string   "party"
    t.string   "phone"
    t.integer  "senate_class"
    t.integer  "state_id"
    t.string   "state_rank"
    t.date     "term_end"
    t.date     "term_start"
    t.string   "title"
    t.string   "verified_first_name"
    t.string   "verified_last_name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "legislators", ["bioguide_id"], name: "index_legislators_on_bioguide_id", unique: true, using: :btree
  add_index "legislators", ["district_id"], name: "index_legislators_on_district_id", using: :btree
  add_index "legislators", ["state_id"], name: "index_legislators_on_state_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.string   "abbrev"
    t.boolean  "single_district"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "states", ["abbrev"], name: "index_states_on_abbrev", unique: true, using: :btree
  add_index "states", ["name"], name: "index_states_on_name", unique: true, using: :btree

  create_table "targets", force: :cascade do |t|
    t.integer  "campaign_id"
    t.integer  "legislator_id"
    t.integer  "priority"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "targets", ["campaign_id"], name: "index_targets_on_campaign_id", using: :btree
  add_index "targets", ["legislator_id", "campaign_id"], name: "index_targets_on_legislator_id_and_campaign_id", unique: true, using: :btree
  add_index "targets", ["legislator_id"], name: "index_targets_on_legislator_id", using: :btree

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
  add_foreign_key "legislators", "districts"
  add_foreign_key "legislators", "states"
  add_foreign_key "targets", "campaigns"
  add_foreign_key "targets", "legislators"
  add_foreign_key "zip_codes", "states"
end
