class AddPrioritizationFieldsToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :priority, :integer
    add_column :defects, :severity, :integer
    add_column :defects, :risk, :integer
  end

  def self.down
    remove_column :defects, :risk
    remove_column :defects, :severity
    remove_column :defects, :priority
  end
end
