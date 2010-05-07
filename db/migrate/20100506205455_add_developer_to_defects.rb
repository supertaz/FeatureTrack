class AddDeveloperToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :developer_id, :integer
  end

  def self.down
    remove_column :defects, :developer_id
  end
end
