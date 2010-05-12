class AddStoryTypeToDefect < ActiveRecord::Migration
  def self.up
    add_column :defects, :story_type, :string
  end

  def self.down
    remove_column :defects, :story_type
  end
end
