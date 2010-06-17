class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.integer :source_id
      t.string :story_source
      t.string :title
      t.text :description
      t.integer :project_id
      t.string :story_type
      t.string :status
      t.integer :owner_id
      t.datetime :accepted_at
      t.timestamps
    end
    add_index :stories, [:story_source, :source_id], :unique => true
    add_index :stories, [:project_id, :status]
    add_index :stories, :status

    create_table :defects_stories, :id => false do |t|
      t.integer :defect_id
      t.integer :story_id
    end
    add_index :defects_stories, [:defect_id, :story_id]
    add_index :defects_stories, [:story_id, :defect_id]

    create_table :feature_requests_stories, :id => false do |t|
      t.integer :feature_request_id
      t.integer :story_id
    end
    add_index :feature_requests_stories, [:feature_request_id, :story_id]
    add_index :feature_requests_stories, [:story_id, :feature_request_id]
  end

  def self.down
    drop_table :stories
    drop_table :defects_stories
    drop_table :feature_requests_stories
  end
end
