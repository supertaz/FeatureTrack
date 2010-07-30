class AddAdditionalCounterAndIndexesToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :open_story_count, :integer
    add_index :stories, [:status, :open_story_count]
    add_index :stories, :open_story_count
  end

  def self.down
    remove_column :stories, :open_story_count
  end
end
