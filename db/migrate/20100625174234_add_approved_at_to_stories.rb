class AddApprovedAtToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :approved_at, :datetime
    add_column :stories, :rejected_at, :datetime
  end

  def self.down
    remove_column :stories, :approved_at
    remove_column :stories, :rejected_at
  end
end
