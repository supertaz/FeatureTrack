class AddWhoAndWhatToDefects < ActiveRecord::Migration
  def self.up
    add_column :defects, :affected, :string
    add_column :defects, :functional_area, :string
  end

  def self.down
    remove_column :defects, :functional_area
    remove_column :defects, :affected
  end
end
