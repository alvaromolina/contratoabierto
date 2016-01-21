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

ActiveRecord::Schema.define(version: 20160121203253) do

  create_table "applying_companies", force: true do |t|
    t.integer  "contract_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applying_companies", ["company_id"], name: "index_applying_companies_on_company_id", using: :btree
  add_index "applying_companies", ["contract_id"], name: "index_applying_companies_on_contract_id", using: :btree

  create_table "awarding_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budget_items", force: true do |t|
    t.string   "origin_number"
    t.string   "item_number"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "company_type"
    t.string   "document_type"
    t.string   "document_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company_origin"
  end

  create_table "contract_budget_items", force: true do |t|
    t.integer  "contract_id"
    t.integer  "budget_item_id"
    t.text     "description"
    t.string   "contract_number"
    t.decimal  "unit_price"
    t.string   "quantity_type"
    t.decimal  "quantity"
    t.decimal  "total"
    t.string   "origin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_budget_items", ["budget_item_id"], name: "index_contract_budget_items_on_budget_item_id", using: :btree
  add_index "contract_budget_items", ["contract_id"], name: "index_contract_budget_items_on_contract_id", using: :btree

  create_table "contract_documents", force: true do |t|
    t.integer  "contract_id"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_documents", ["contract_id"], name: "index_contract_documents_on_contract_id", using: :btree

  create_table "contract_forms", force: true do |t|
    t.integer  "contract_id"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "process_status"
  end

  add_index "contract_forms", ["contract_id"], name: "index_contract_forms_on_contract_id", using: :btree
  add_index "contract_forms", ["name"], name: "index_contract_forms_on_name", using: :btree

  create_table "contract_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracted_companies", force: true do |t|
    t.integer  "contract_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contract_number"
    t.datetime "contract_date"
    t.decimal  "contract_amount"
    t.string   "currency"
    t.decimal  "exchange"
  end

  add_index "contracted_companies", ["company_id"], name: "index_contracted_companies_on_company_id", using: :btree
  add_index "contracted_companies", ["contract_id"], name: "index_contracted_companies_on_contract_id", using: :btree

  create_table "contracts", force: true do |t|
    t.string   "origin_id"
    t.integer  "entity_id"
    t.integer  "mode_id"
    t.string   "control_number"
    t.integer  "publication_number"
    t.text     "description"
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
    t.decimal  "contracted_amount"
    t.integer  "selection_method_id"
    t.integer  "awarding_type_id"
    t.integer  "contract_type_id"
    t.string   "warranty_asked"
    t.string   "currency_contract"
    t.decimal  "specified_amount"
    t.integer  "motive_id"
  end

  add_index "contracts", ["awarding_type_id"], name: "index_contracts_on_awarding_type_id", using: :btree
  add_index "contracts", ["contract_type_id"], name: "index_contracts_on_contract_type_id", using: :btree
  add_index "contracts", ["description"], name: "index_contracts_on_description", using: :btree
  add_index "contracts", ["entity_id"], name: "index_contracts_on_entity_id", using: :btree
  add_index "contracts", ["mode_id"], name: "index_contracts_on_mode_id", using: :btree
  add_index "contracts", ["motive_id"], name: "index_contracts_on_motive_id", using: :btree
  add_index "contracts", ["publication_date"], name: "index_contracts_on_publication_date", using: :btree
  add_index "contracts", ["region_id"], name: "index_contracts_on_region_id", using: :btree
  add_index "contracts", ["regulation_id"], name: "index_contracts_on_regulation_id", using: :btree
  add_index "contracts", ["selection_method_id"], name: "index_contracts_on_selection_method_id", using: :btree
  add_index "contracts", ["status_id"], name: "index_contracts_on_status_id", using: :btree

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

  create_table "motives", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "relation_companies", force: true do |t|
    t.integer  "parent_company_id"
    t.integer  "children_company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "selection_methods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin_code"
  end

end
