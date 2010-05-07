class AddBasicMetadataToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :active, :boolean
    add_column :projects, :archived, :boolean
    add_column :projects, :test_project, :boolean
    add_column :projects, :allow_features, :boolean
    add_column :projects, :allow_bugs, :boolean
    add_column :projects, :allow_chores, :boolean
    add_column :projects, :allow_releases, :boolean
    add_column :projects, :start_at, :date
    add_column :projects, :end_at, :date
  end

  def self.down
    remove_column :projects, :end_at
    remove_column :projects, :start_at
    remove_column :projects, :allow_releases
    remove_column :projects, :allow_chores
    remove_column :projects, :allow_bugs
    remove_column :projects, :allow_features
    remove_column :projects, :test_project
    remove_column :projects, :archived
    remove_column :projects, :active
  end
end
