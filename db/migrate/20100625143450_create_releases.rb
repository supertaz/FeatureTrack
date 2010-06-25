class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.string :name
      t.datetime :code_freeze_on
      t.datetime :merge_on
      t.datetime :push_on
      t.text :description
      t.timestamps
    end
    add_index :releases, :push_on
    add_index :releases, :code_freeze_on
    add_index :releases, :merge_on

    create_table :release_notes do |t|
      t.string :title
      t.text :description
      t.timestamps
    end

    create_table :release_notes_stories, :id => false do |t|
      t.integer :release_note_id, :null => false, :default => 0
      t.integer :story_id, :null => false, :default => 0
    end
    add_index :release_notes_stories, [:release_note_id, :story_id], :name => 'rn_story_rn_story_idx'
    add_index :release_notes_stories, [:story_id, :release_note_id], :name => 'rn_story_story_rn_idx'

    add_column :stories, :release_id, :integer
  end
  
  def self.down
    drop_table :releases
    drop_table :release_notes
    drop_table :release_notes_stories
    remove_column :stories, :release_id
  end
end
