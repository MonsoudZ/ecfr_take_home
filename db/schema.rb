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

ActiveRecord::Schema[7.2].define(version: 2025_05_28_200215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chapters", force: :cascade do |t|
    t.string "identifier"
    t.string "label"
    t.integer "ecfr_title_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ecfr_titles", force: :cascade do |t|
    t.integer "number", null: false
    t.string "name", null: false
    t.date "latest_amended_on"
    t.date "latest_issue_date"
    t.date "up_to_date_as_of"
    t.boolean "reserved", default: false
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_amended_on"], name: "index_ecfr_titles_on_latest_amended_on"
    t.index ["number"], name: "index_ecfr_titles_on_number", unique: true
    t.index ["reserved"], name: "index_ecfr_titles_on_reserved"
  end

  create_table "parts", force: :cascade do |t|
    t.string "identifier"
    t.string "label"
    t.integer "chapter_id"
    t.integer "position"
    t.string "agency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_parts_on_chapter_id"
    t.index ["identifier"], name: "index_parts_on_identifier"
  end

  create_table "sections", force: :cascade do |t|
    t.string "agency"
    t.string "part"
    t.string "section"
    t.text "text"
    t.integer "word_count"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "title_number"
    t.integer "part_id"
    t.integer "subpart_id"
    t.index ["part_id"], name: "index_sections_on_part_id"
    t.index ["subpart_id"], name: "index_sections_on_subpart_id"
  end

  create_table "subparts", force: :cascade do |t|
    t.string "identifier"
    t.string "label"
    t.integer "part_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_subparts_on_identifier"
    t.index ["part_id"], name: "index_subparts_on_part_id"
  end

  add_foreign_key "sections", "parts"
  add_foreign_key "sections", "subparts"
end
