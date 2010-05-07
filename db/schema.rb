# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100506233749) do

  create_table "defects", :force => true do |t|
    t.string   "status"
    t.string   "story_source"
    t.integer  "story_id"
    t.string   "title"
    t.integer  "reporter_id"
    t.integer  "owner_id"
    t.integer  "tester_id"
    t.integer  "approver_id"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "finished_at"
    t.datetime "delivered_at"
    t.datetime "started_at"
    t.datetime "last_assigned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "priority"
    t.integer  "severity"
    t.integer  "risk"
    t.integer  "execution_priority"
    t.string   "affected"
    t.string   "functional_area"
    t.integer  "against_story_id"
    t.string   "against_story_source"
    t.integer  "developer_id"
    t.integer  "environment_id"
  end

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.datetime "enable_at"
    t.datetime "disable_at"
    t.string   "restricted_to"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "archived"
    t.boolean  "test_project"
    t.boolean  "allow_features"
    t.boolean  "allow_bugs"
    t.boolean  "allow_chores"
    t.boolean  "allow_releases"
    t.date     "start_at"
    t.date     "end_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "source_api_keys", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "api_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count"
    t.integer  "failed_login_count"
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "last_read_at"
    t.datetime "last_issue_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "home"
    t.string   "work"
    t.string   "mobile"
    t.string   "nickname"
    t.boolean  "active"
  end

end
