class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :story_id
      t.string :subject
      t.text :body
      t.integer :author_id

      t.timestamps
    end
    add_index :notes, :story_id
    add_index :notes, :author_id
  end

  def self.down
    drop_table :notes
  end
end
