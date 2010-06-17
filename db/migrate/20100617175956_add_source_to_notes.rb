class AddSourceToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :story_source, :string
    add_column :notes, :source_id, :integer
    add_index :notes, [:story_source, :source_id]
  end

  def self.down
    remove_column :notes, :source_id
    remove_column :notes, :story_source
  end
end
