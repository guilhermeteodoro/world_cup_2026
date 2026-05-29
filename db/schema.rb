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

ActiveRecord::Schema[8.1].define(version: 2026_05_29_205315) do
  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.string "emoji", null: false
    t.string "name", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "stickers", force: :cascade do |t|
    t.integer "category", null: false
    t.integer "country_id", null: false
    t.string "number", null: false
    t.integer "position", null: false
    t.index ["category"], name: "index_stickers_on_category"
    t.index ["country_id", "number"], name: "index_stickers_on_country_id_and_number", unique: true
    t.index ["country_id"], name: "index_stickers_on_country_id"
    t.index ["position"], name: "index_stickers_on_position", unique: true
  end

  create_table "user_stickers", force: :cascade do |t|
    t.integer "copies", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "sticker_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["sticker_id"], name: "index_user_stickers_on_sticker_id"
    t.index ["user_id", "sticker_id"], name: "index_user_stickers_on_user_id_and_sticker_id", unique: true
    t.index ["user_id"], name: "index_user_stickers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "stickers", "countries"
  add_foreign_key "user_stickers", "stickers"
  add_foreign_key "user_stickers", "users"
end
