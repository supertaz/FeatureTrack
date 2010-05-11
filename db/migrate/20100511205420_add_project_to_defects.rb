class AddProjectToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :project_id, :integer
  end

  def self.down
    remove_column :defects, :project_id
  end
end
