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

ActiveRecord::Schema.define(version: 2018_07_09_210823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ellie_shopify_orders", force: :cascade do |t|
    t.string "order_name"
    t.bigint "order_id"
    t.datetime "created_at"
    t.string "email"
    t.jsonb "line_items"
    t.string "tracking_company"
    t.string "tracking_number"
    t.boolean "is_tracking_updated", default: false
  end

  create_table "marika_shopify_orders", force: :cascade do |t|
    t.string "order_name"
    t.bigint "order_id"
    t.datetime "created_at"
    t.string "email"
    t.jsonb "line_items"
    t.string "tracking_company"
    t.string "tracking_number"
    t.boolean "is_tracking_updated", default: false
  end

end
