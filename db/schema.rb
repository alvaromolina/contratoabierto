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

ActiveRecord::Schema.define(version: 20150414231801) do

  create_table "contract_documents", force: true do |t|
    t.integer  "contract_id"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_documents", ["contract_id"], name: "index_contract_documents_on_contract_id"

  create_table "contract_forms", force: true do |t|
    t.integer  "contract_id"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_forms", ["contract_id"], name: "index_contract_forms_on_contract_id"

  create_table "contracts", force: true do |t|
    t.string   "origin_id"
    t.integer  "entity_id"
    t.integer  "mode_id"
    t.string   "control_number"
    t.integer  "publication_number"
    t.string   "description"
    t.integer  "status_id"
    t.integer  "contracted_amount_cents"
    t.string   "contracted_amount_currency"
    t.date     "publication_date"
    t.date     "presentation_date"
    t.string   "contact"
    t.string   "warranty"
    t.string   "specification_price"
    t.datetime "aclaration_date"
    t.date     "granted_date"
    t.date     "abandonment_date"
    t.integer  "region_id"
    t.integer  "regulation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracts", ["entity_id"], name: "index_contracts_on_entity_id"
  add_index "contracts", ["mode_id"], name: "index_contracts_on_mode_id"
  add_index "contracts", ["region_id"], name: "index_contracts_on_region_id"
  add_index "contracts", ["regulation_id"], name: "index_contracts_on_regulation_id"
  add_index "contracts", ["status_id"], name: "index_contracts_on_status_id"

  create_table "crawlers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "modes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin_code"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin_code"
  end

  create_table "regulations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin_code"
  end

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin_code"
  end

end
