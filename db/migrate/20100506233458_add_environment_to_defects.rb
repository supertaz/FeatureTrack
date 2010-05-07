class AddEnvironmentToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :environment_id, :integer
  end

  def self.down
    remove_column :defects, :environment_id
  end
end
