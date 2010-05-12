class AddProjectToFeatureRequests < ActiveRecord::Migration
  def self.up
    add_column :feature_requests, :project_id, :integer
  end

  def self.down
    remove_column :feature_requests, :project_id
  end
end
