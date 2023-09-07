# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_07_074633) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "imports", force: :cascade do |t|
    t.string "source", null: false
    t.string "status", null: false
    t.integer "progress", default: 0, null: false
    t.bigint "user_id", null: false
    t.string "timestamps"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "metrics", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["metric_date"], name: "index_metrics_on_metric_date"
    t.index ["user_id", "app_title"], name: "index_metrics_on_user_id_and_app_title"
    t.index ["user_id", "charge_type"], name: "index_metrics_on_user_id_and_charge_type"
    t.index ["user_id", "metric_date"], name: "index_metrics_on_user_id_and_metric_date"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.date "payment_date"
    t.text "charge_type"
    t.text "app_title"
    t.text "shop"
    t.decimal "revenue", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.string "shop_country"
    t.index ["payment_date"], name: "index_payments_on_payment_date"
    t.index ["user_id", "app_title"], name: "index_payments_on_user_id_and_app_title"
    t.index ["user_id", "charge_type", "app_title"], name: "payment_histories_user_charge_title_index"
    t.index ["user_id", "charge_type"], name: "index_payments_on_user_id_and_charge_type"
    t.index ["user_id", "payment_date", "charge_type", "app_title", "shop"], name: "payment_histories_full_index"
    t.index ["user_id", "payment_date"], name: "index_payments_on_user_id_and_payment_date"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "import"
    t.integer "import_status", default: 0
    t.string "partner_api_access_token"
    t.integer "partner_api_organization_id"
    t.boolean "count_usage_charges_as_recurring", default: false
    t.text "partner_api_errors"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "imports", "users"
end
