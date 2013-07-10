# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130626164608) do

  create_table "admins", force: true do |t|
    t.string   "email",                              null: false
    t.boolean  "can_change_admins",  default: false, null: false
    t.boolean  "can_create_surveys", default: false, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
    t.string   "password_salt"
    t.string   "password_hash"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree

  create_table "survey_permissions", force: true do |t|
    t.integer  "admin_id",          null: false
    t.integer  "survey_id",         null: false
    t.boolean  "can_modify_survey"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "survey_questions", force: true do |t|
    t.integer  "survey_id"
    t.string   "question_text", default: "", null: false
    t.integer  "position",      default: 0,  null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: true do |t|
    t.string   "name",                                         null: false
    t.integer  "samples_per_day",              default: 4,     null: false
    t.integer  "mean_minutes_between_samples", default: 60,    null: false
    t.integer  "sample_minutes_plusminus",     default: 15,    null: false
    t.boolean  "active",                       default: false, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "twilio_numbers", force: true do |t|
    t.integer  "survey_id",        null: false
    t.string   "account_sid",      null: false
    t.string   "auth_token",       null: false
    t.string   "phone_number",     null: false
    t.string   "phone_number_sid", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twilio_numbers", ["phone_number"], name: "index_twilio_numbers_on_phone_number", unique: true, using: :btree

end
