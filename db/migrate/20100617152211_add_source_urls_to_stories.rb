class AddSourceUrlsToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :source_url, :text
    add_column :stories, :assignee_id, :integer
  end

  def self.down
    remove_column :stories, :source_url
    remove_column :stories, :assignee_id
  end
end
