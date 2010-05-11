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

ActiveRecord::Schema.define(:version => 20100511205420) do

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
    t.integer  "project_id"
  end

  add_index "defects", ["against_story_source", "against_story_id", "status", "id"], :name => "dfct_story_stat"
  add_index "defects", ["developer_id", "status", "id"], :name => "dfct_dev_stat"
  add_index "defects", ["environment_id", "status", "id"], :name => "dfct_env_stat"
  add_index "defects", ["execution_priority", "status", "id"], :name => "dfct_execpri_stat"
  add_index "defects", ["owner_id", "status", "id"], :name => "dfct_owner_stat"
  add_index "defects", ["priority", "status", "id"], :name => "dfct_pri_stat"
  add_index "defects", ["reporter_id", "status", "id"], :name => "dfct_rpt_stat"
  add_index "defects", ["risk", "execution_priority", "id"], :name => "dfct_risk_execpri"
  add_index "defects", ["severity", "status", "id"], :name => "dfct_sev_stat"
  add_index "defects", ["status", "severity", "execution_priority", "id"], :name => "dfct_stat_sev_execpri"
  add_index "defects", ["tester_id", "status", "id"], :name => "dfct_tester_stat"

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.datetime "enable_at"
    t.datetime "disable_at"
    t.string   "restricted_to"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "environments", ["name", "id"], :name => "index_environments_on_name_and_id"

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

  add_index "projects", ["active", "id"], :name => "index_projects_on_active_and_id"
  add_index "projects", ["active", "name", "id"], :name => "index_projects_on_active_and_name_and_id"
  add_index "projects", ["test_project", "active", "id"], :name => "prj_test_act"
  add_index "projects", ["test_project", "active", "name", "id"], :name => "prj_tst_act_nm"

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["id", "name"], :name => "index_roles_on_id_and_name"
  add_index "roles", ["name", "authorizable_type", "authorizable_id", "id"], :name => "name_auth_info_id", :unique => true
  add_index "roles", ["name", "authorizable_type", "id"], :name => "name_auth_type_id", :unique => true
  add_index "roles", ["name", "id"], :name => "index_roles_on_name_and_id"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id", :unique => true

  create_table "source_api_keys", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "api_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "source_api_keys", ["source", "user_id", "id"], :name => "sak_src_usr"
  add_index "source_api_keys", ["user_id", "source", "id"], :name => "sak_usr_src"

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

  add_index "users", ["active", "id"], :name => "index_users_on_active_and_id"
  add_index "users", ["email", "firstname", "lastname", "nickname", "id"], :name => "users_by_email_name_id"
  add_index "users", ["email", "id"], :name => "index_users_on_email_and_id", :unique => true
  add_index "users", ["firstname", "lastname", "id"], :name => "users_by_name"
  add_index "users", ["id", "email", "firstname", "lastname", "nickname"], :name => "users_by_id_email_name"

end
