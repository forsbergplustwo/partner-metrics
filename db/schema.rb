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

ActiveRecord::Schema.define(version: 20210326140955) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "metrics", force: :cascade do |t|
    t.date "metric_date"
    t.text "charge_type"
    t.text "app_title"
    t.decimal "revenue", precision: 10, scale: 2
    t.integer "number_of_charges"
    t.integer "number_of_shops"
    t.integer "repeat_customers"
    t.decimal "repeat_vs_new_customers", precision: 10, scale: 2
    t.decimal "average_revenue_per_shop", precision: 10, scale: 2
    t.decimal "average_revenue_per_charge", precision: 10, scale: 2
    t.decimal "shop_churn", precision: 10, scale: 2
    t.decimal "revenue_churn", precision: 10, scale: 2
    t.decimal "lifetime_value", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
  end

  add_index "metrics", ["user_id", "app_title"], name: "index_metrics_on_user_id_and_app_title", using: :btree
  add_index "metrics", ["user_id", "charge_type"], name: "index_metrics_on_user_id_and_charge_type", using: :btree
  add_index "metrics", ["user_id", "metric_date"], name: "index_metrics_on_user_id_and_metric_date", using: :btree

  create_table "payment_histories", force: :cascade do |t|
    t.date "payment_date"
    t.text "charge_type"
    t.text "app_title"
    t.text "shop"
    t.decimal "revenue", precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "shop_country", limit: 255
  end

  add_index "payment_histories", ["user_id", "app_title"], name: "index_payment_histories_on_user_id_and_app_title", using: :btree
  add_index "payment_histories", ["user_id", "charge_type"], name: "index_payment_histories_on_user_id_and_charge_type", using: :btree
  add_index "payment_histories", ["user_id", "payment_date", "charge_type", "app_title", "shop"], name: "payment_histories_full_index", using: :btree
  add_index "payment_histories", ["user_id", "payment_date"], name: "index_payment_histories_on_user_id_and_payment_date", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "import", limit: 255
    t.integer "import_status", default: 0
    t.string "partner_api_access_token"
    t.integer "partner_api_organization_id"
    t.boolean "count_usage_charges_as_recurring", default: false
    t.text "partner_api_errors"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
end
