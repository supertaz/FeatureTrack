class AddInvalidFlagToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :invalid, :boolean, :default => false
  end

  def self.down
    remove_column :defects, :invalid
  end
end
