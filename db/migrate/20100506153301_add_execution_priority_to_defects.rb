class AddExecutionPriorityToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :execution_priority, :integer
  end

  def self.down
    remove_column :defects, :execution_priority
  end
end
