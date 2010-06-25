class AddDefectAndFeatureFieldsToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :approver_id, :integer
    add_column :stories, :requestor_id, :integer
    add_column :stories, :priority, :integer
    add_column :stories, :affected, :string
    add_column :stories, :functional_area, :string
    add_column :stories, :risk, :integer
    add_column :stories, :reviewer_id, :integer
    add_column :stories, :developer_id, :integer
    add_column :stories, :tester_id, :integer
    add_column :stories, :environment_id, :integer
    add_column :stories, :reviewed_at, :datetime
    add_column :stories, :invalid, :boolean
    add_column :stories, :last_assigned_at, :datetime
    add_column :stories, :execution_priority, :integer
    add_column :stories, :against_story_id, :integer
    add_column :stories, :delivered_at, :datetime
    add_column :stories, :severity, :integer
    add_column :stories, :started_at, :datetime
    add_column :stories, :finished_at, :datetime
    add_index :stories, [:requestor_id]
    add_index :stories, [:story_type]
    add_index :stories, [:project_id, :story_type]
  end

  def self.down
    remove_column :stories, :finished_at
    remove_column :stories, :started_at
    remove_column :stories, :severity
    remove_column :stories, :delivered_at
    remove_column :stories, :against_story_id
    remove_column :stories, :execution_priority
    remove_column :stories, :last_assigned_at
    remove_column :stories, :invalid
    remove_column :stories, :reviewed_at
    remove_column :stories, :environment_id
    remove_column :stories, :tester_id
    remove_column :stories, :developer_id
    remove_column :stories, :reviewer_id
    remove_column :stories, :risk
    remove_column :stories, :functional_area
    remove_column :stories, :affected
    remove_column :stories, :priority
    remove_column :stories, :requestor_id
    remove_column :stories, :approver_id
  end
end
