class AddDefectCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :linked_story_count, :integer, :null => false, :default => 0
    add_index :stories, :linked_story_count
    add_index :stories, [:status, :linked_story_count]
  end

  def self.down
    remove_column :stories, :linked_story_count
  end
end
