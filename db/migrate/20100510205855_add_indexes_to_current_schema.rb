class AddIndexesToCurrentSchema < ActiveRecord::Migration
  def self.up
    # roles
    add_index :roles, [:id, :name]
    add_index :roles, [:name, :id]
    add_index :roles, [:name, :authorizable_type, :id], :name => 'name_auth_type_id', :unique => true
    add_index :roles, [:name, :authorizable_type, :authorizable_id, :id], :name => 'name_auth_info_id', :unique => true

    # roles_users
    add_index :roles_users, [:user_id, :role_id], :unique => true
    add_index :roles_users, [:role_id, :user_id], :unique => true

    # users
    add_index :users, [:email, :id], :unique => true
    add_index :users, [:id, :email, :firstname, :lastname, :nickname], :name => 'users_by_id_email_name'
    add_index :users, [:email, :firstname, :lastname, :nickname, :id], :name => 'users_by_email_name_id'
    add_index :users, [:firstname, :lastname, :id], :name => 'users_by_name'
    add_index :users, [:active, :id]

    # projects
    add_index :projects, [:test_project, :active, :name, :id], :name => 'prj_tst_act_nm'
    add_index :projects, [:test_project, :active, :id], :name => 'prj_test_act'
    add_index :projects, [:active, :name, :id]
    add_index :projects, [:active, :id]

    # source_api_keys
    add_index :source_api_keys, [:source, :user_id, :id], :name => 'sak_src_usr'
    add_index :source_api_keys, [:user_id, :source, :id], :name => 'sak_usr_src'

    # environments
    add_index :environments, [:name, :id]

    # defects
    add_index :defects, [:status, :severity, :execution_priority, :id], :name => 'dfct_stat_sev_execpri'
    add_index :defects, [:severity, :status, :id], :name => 'dfct_sev_stat'
    add_index :defects, [:priority, :status, :id], :name => 'dfct_pri_stat'
    add_index :defects, [:execution_priority, :status, :id], :name => 'dfct_execpri_stat'
    add_index :defects, [:risk, :execution_priority, :id], :name => 'dfct_risk_execpri'
    add_index :defects, [:against_story_source, :against_story_id, :status, :id], :name => 'dfct_story_stat'
    add_index :defects, [:reporter_id, :status, :id], :name => 'dfct_rpt_stat'
    add_index :defects, [:owner_id, :status, :id], :name => 'dfct_owner_stat'
    add_index :defects, [:tester_id, :status, :id], :name => 'dfct_tester_stat'
    add_index :defects, [:developer_id, :status, :id], :name => 'dfct_dev_stat'
    add_index :defects, [:environment_id, :status, :id], :name => 'dfct_env_stat'

  end

  def self.down
  end
end
