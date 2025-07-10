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

ActiveRecord::Schema[8.0].define(version: 2025_07_10_181641) do
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
    t.index ["period_end"], name: "index_ai_summaries_on_period_end"
    t.index ["period_start"], name: "index_ai_summaries_on_period_start"
    t.index ["summary_type", "period_start", "period_end"], name: "index_ai_summaries_on_type_and_period", unique: true
    t.index ["summary_type"], name: "index_ai_summaries_on_summary_type"
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
  end

  create_table "progress_entries", force: :cascade do |t|
    t.text "content"
    t.date "entry_date"
    t.bigint "goal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_date"], name: "index_progress_entries_on_entry_date", unique: true
    t.index ["goal_id"], name: "index_progress_entries_on_goal_id"
  end

  add_foreign_key "progress_entries", "goals"
end
