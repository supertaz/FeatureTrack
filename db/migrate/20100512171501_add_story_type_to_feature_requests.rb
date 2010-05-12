class AddStoryTypeToFeatureRequests < ActiveRecord::Migration
  def self.up
    add_column :feature_requests, :story_type, :string
  end

  def self.down
    remove_column :feature_requests, :story_type
  end
end
