class AddStoryIdToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :against_story_id, :integer
    add_column :defects, :against_story_source, :string
  end

  def self.down
    remove_column :defects, :against_story_id
    remove_column :defects, :against_story_source
  end
end
