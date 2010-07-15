class AddIndexesToProjects < ActiveRecord::Migration
  def self.up
    add_index :projects, [:active, :test_project]
    add_index :stories, [:against_story_id]
    add_index :stories, [:status, :against_story_id]
  end

  def self.down
    remove_index :projects,  [:active, :test_project]
    remove_index :stories, [:against_story_id]
    remove_index :stories, [:status, :against_story_id]
  end
end
