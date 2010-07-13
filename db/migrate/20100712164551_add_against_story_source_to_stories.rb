class AddAgainstStorySourceToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :against_story_source, :string
  end

  def self.down
    remove_column :stories, :against_story_source
  end
end
