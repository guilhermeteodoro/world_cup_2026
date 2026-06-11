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

ActiveRecord::Schema[8.1].define(version: 2026_06_11_001521) do
  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.string "color"
    t.datetime "deleted_at"
    t.string "emoji", null: false
    t.string "group_name"
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["deleted_at"], name: "index_countries_on_deleted_at"
  end

  create_table "stickers", force: :cascade do |t|
    t.integer "category", null: false
    t.integer "country_id", null: false
    t.datetime "deleted_at"
    t.string "name"
    t.string "number", null: false
    t.integer "position", null: false
    t.index ["category"], name: "index_stickers_on_category"
    t.index ["country_id", "number"], name: "index_stickers_on_country_id_and_number", unique: true
    t.index ["country_id"], name: "index_stickers_on_country_id"
    t.index ["deleted_at"], name: "index_stickers_on_deleted_at"
    t.index ["position"], name: "index_stickers_on_position", unique: true
  end

  create_table "trade_stickers", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "giver_id", null: false
    t.integer "receiver_id", null: false
    t.integer "sticker_id", null: false
    t.integer "trade_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_sticker_id"
    t.index ["deleted_at"], name: "index_trade_stickers_on_deleted_at"
    t.index ["giver_id"], name: "index_trade_stickers_on_giver_id"
    t.index ["receiver_id"], name: "index_trade_stickers_on_receiver_id"
    t.index ["sticker_id"], name: "index_trade_stickers_on_sticker_id"
    t.index ["trade_id", "sticker_id"], name: "index_trade_stickers_on_trade_id_and_sticker_id", unique: true
    t.index ["trade_id"], name: "index_trade_stickers_on_trade_id"
    t.index ["user_sticker_id"], name: "index_trade_stickers_on_user_sticker_id"
  end

  create_table "trades", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "updated_at", null: false
    t.datetime "user_a_accepted_at"
    t.datetime "user_a_auto_agreed_at"
    t.integer "user_a_id", null: false
    t.datetime "user_a_receipt_ended_at"
    t.datetime "user_b_accepted_at"
    t.datetime "user_b_auto_agreed_at"
    t.integer "user_b_id", null: false
    t.datetime "user_b_receipt_ended_at"
    t.index ["deleted_at"], name: "index_trades_on_deleted_at"
    t.index ["user_a_id"], name: "index_trades_on_user_a_id"
    t.index ["user_b_id"], name: "index_trades_on_user_b_id"
  end

  create_table "user_stickers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "state"
    t.integer "sticker_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["deleted_at"], name: "index_user_stickers_on_deleted_at"
    t.index ["state"], name: "index_user_stickers_on_state"
    t.index ["sticker_id"], name: "index_user_stickers_on_sticker_id"
    t.index ["user_id", "sticker_id"], name: "index_user_stickers_unique_glued", unique: true, where: "state = 'glued' AND deleted_at IS NULL"
    t.index ["user_id"], name: "index_user_stickers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "stickers", "countries"
  add_foreign_key "trade_stickers", "stickers"
  add_foreign_key "trade_stickers", "trades"
  add_foreign_key "trade_stickers", "users", column: "giver_id"
  add_foreign_key "trade_stickers", "users", column: "receiver_id"
  add_foreign_key "trades", "users", column: "user_a_id"
  add_foreign_key "trades", "users", column: "user_b_id"
  add_foreign_key "user_stickers", "stickers"
  add_foreign_key "user_stickers", "users"
end
