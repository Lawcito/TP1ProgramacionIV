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

ActiveRecord::Schema[8.1].define(version: 2026_09_29_160148) do
  create_table "courts", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.boolean "covered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_courts_on_name", unique: true
  end

  create_table "deposits", force: :cascade do |t|
    t.integer "reservation_id", null: false
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_deposits_on_reservation_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "court_id", null: false
    t.integer "time_slot_id", null: false
    t.date "date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_reservations_on_court_id"
    t.index ["time_slot_id"], name: "index_reservations_on_time_slot_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "day_of_week"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "deposits", "reservations"
  add_foreign_key "reservations", "courts"
  add_foreign_key "reservations", "time_slots"
  add_foreign_key "reservations", "users"
end
