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

ActiveRecord::Schema[8.0].define(version: 2025_07_10_220950) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ai_summaries", force: :cascade do |t|
    t.text "content", null: false
    t.string "summary_type", null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["period_end"], name: "index_ai_summaries_on_period_end"
    t.index ["period_start"], name: "index_ai_summaries_on_period_start"
    t.index ["summary_type"], name: "index_ai_summaries_on_summary_type"
    t.index ["user_id", "summary_type", "period_start", "period_end"], name: "index_ai_summaries_on_user_type_and_period", unique: true
    t.index ["user_id"], name: "index_ai_summaries_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "target_date"
    t.string "goal_type"
    t.datetime "completed_at"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "progress_entries", force: :cascade do |t|
    t.text "content"
    t.date "entry_date"
    t.bigint "goal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["goal_id"], name: "index_progress_entries_on_goal_id"
    t.index ["user_id", "entry_date"], name: "index_progress_entries_on_user_id_and_entry_date", unique: true
    t.index ["user_id"], name: "index_progress_entries_on_user_id"
  end

  create_table "summaries", force: :cascade do |t|
    t.string "summary_type", null: false
    t.text "content"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["end_date"], name: "index_summaries_on_end_date"
    t.index ["start_date"], name: "index_summaries_on_start_date"
    t.index ["summary_type"], name: "index_summaries_on_summary_type"
    t.index ["user_id", "summary_type", "start_date", "end_date"], name: "index_summaries_uniqueness", unique: true
    t.index ["user_id"], name: "index_summaries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "anthropic_api_key"
    t.string "openai_api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ai_summaries", "users"
  add_foreign_key "goals", "users"
  add_foreign_key "progress_entries", "goals"
  add_foreign_key "progress_entries", "users"
  add_foreign_key "summaries", "users"
end
