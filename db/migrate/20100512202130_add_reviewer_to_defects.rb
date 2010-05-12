class AddReviewerToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :reviewer_id, :integer
    add_column :defects, :reviewed_at, :datetime
  end

  def self.down
    remove_column :defects, :reviewed_at
    remove_column :defects, :reviewer_id
  end
end
