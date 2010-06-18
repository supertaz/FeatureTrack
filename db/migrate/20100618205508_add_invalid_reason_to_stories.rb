class AddInvalidReasonToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :invalid_reason, :text
  end

  def self.down
    remove_column :stories, :invalid_reason
  end
end
