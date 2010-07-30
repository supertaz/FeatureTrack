class CreateAttachedFiles < ActiveRecord::Migration
  def self.up
    create_table :attached_files do |t|
      t.integer :story_id
      t.integer :attached_by_id
      t.string :attached_file_name
      t.string :attached_content_type
      t.integer :attached_file_size
      t.datetime :attached_updated_at

      t.timestamps
    end

    add_index :attached_files, [:story_id, :id]
  end

  def self.down
    drop_table :attached_files
  end
end
