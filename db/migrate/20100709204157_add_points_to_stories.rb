class AddPointsToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :estimated_points, :integer
    add_column :stories, :current_points, :integer
    add_column :stories, :current_progress, :integer
    add_column :stories, :original_points, :integer
  end

  def self.down
    remove_column :stories, :original_points
    remove_column :stories, :current_progress
    remove_column :stories, :current_points
    remove_column :stories, :estimated_points
  end
end
