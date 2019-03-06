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

ActiveRecord::Schema.define(version: 2019_03_01_153058) do

  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.boolean "can_change_admins", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.binary "password_salt", limit: 1024
    t.binary "password_hash", limit: 1024
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "participants", force: :cascade do |t|
    t.integer "survey_id", null: false
    t.string "phone_number", null: false
    t.boolean "active", default: true, null: false
    t.string "login_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time_zone"
    t.string "external_key"
    t.json "state", default: {}
  end

  create_table "schedule_days", force: :cascade do |t|
    t.integer "participant_id", null: false
    t.date "participant_local_date", null: false
    t.text "time_ranges"
    t.boolean "skip", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "aasm_state"
    t.index ["aasm_state"], name: "index_schedule_days_on_aasm_state"
  end

  create_table "scheduled_messages", force: :cascade do |t|
    t.integer "schedule_day_id", null: false
    t.integer "survey_question_id"
    t.datetime "scheduled_at", null: false
    t.datetime "delivered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "aasm_state"
    t.text "message_text"
    t.text "destination_url"
    t.index ["aasm_state"], name: "index_scheduled_messages_on_aasm_state"
  end

  create_table "survey_permissions", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "survey_id", null: false
    t.boolean "can_modify_survey"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer "survey_id"
    t.string "question_text", default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "twilio_account_sid"
    t.string "twilio_auth_token"
    t.string "phone_number"
    t.string "time_zone"
    t.text "help_message"
    t.string "welcome_message", default: "Welcome to the study! Quit at any time by texting STOP.", null: false
    t.string "type"
    t.json "configuration", default: {}
    t.index ["phone_number", "active"], name: "index_surveys_on_phone_number_and_active"
  end

  create_table "text_messages", force: :cascade do |t|
    t.integer "survey_id", null: false
    t.string "type", null: false
    t.string "from_number", null: false
    t.string "to_number", null: false
    t.string "message", null: false
    t.text "server_response"
    t.datetime "scheduled_at"
    t.datetime "delivered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["survey_id", "from_number"], name: "index_text_messages_on_survey_id_and_from_number"
    t.index ["survey_id", "to_number"], name: "index_text_messages_on_survey_id_and_to_number"
    t.index ["survey_id", "type"], name: "index_text_messages_on_survey_id_and_type"
  end

end
