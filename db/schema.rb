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

ActiveRecord::Schema[8.1].define(version: 2026_02_12_060015) do
  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "failed_count", default: 0
    t.text "message_template", null: false
    t.string "name", null: false
    t.datetime "scheduled_for"
    t.string "segment_tags"
    t.integer "sent_count", default: 0
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["scheduled_for"], name: "index_campaigns_on_scheduled_for"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_collections_on_slug", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "do_not_contact", default: false, null: false
    t.string "first_name", null: false
    t.datetime "last_contacted_at"
    t.string "last_name"
    t.text "notes"
    t.string "opt_in_source"
    t.boolean "opt_in_status", default: false, null: false
    t.datetime "opt_in_timestamp"
    t.string "phone_number", null: false
    t.string "preferred_channel", default: "whatsapp"
    t.string "tags"
    t.string "unsubscribe_reason"
    t.datetime "unsubscribe_timestamp"
    t.datetime "updated_at", null: false
    t.index ["do_not_contact"], name: "index_contacts_on_do_not_contact"
    t.index ["opt_in_status"], name: "index_contacts_on_opt_in_status"
    t.index ["phone_number"], name: "index_contacts_on_phone_number", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "campaign_id", null: false
    t.string "channel", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.text "error_text"
    t.string "provider_message_id"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_messages_on_campaign_id"
    t.index ["contact_id"], name: "index_messages_on_contact_id"
    t.index ["sent_at"], name: "index_messages_on_sent_at"
    t.index ["status"], name: "index_messages_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "collection_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2
    t.boolean "seasonal", default: false, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_products_on_collection_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "campaigns", "users"
  add_foreign_key "messages", "campaigns"
  add_foreign_key "messages", "contacts"
  add_foreign_key "products", "collections"
end
