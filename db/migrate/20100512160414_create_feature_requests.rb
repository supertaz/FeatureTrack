class CreateFeatureRequests < ActiveRecord::Migration
  def self.up
    create_table :feature_requests do |t|
      t.string :status
      t.string :story_source
      t.integer :story_id
      t.string :title
      t.integer :requestor_id
      t.integer :approver_id
      t.datetime :approved_at
      t.datetime :rejected_at
      t.integer :priority
      t.integer :risk
      t.string :affected
      t.string :functional_area
      t.text :description
      t.timestamps
    end
    add_index :feature_requests, [:status, :id]
    add_index :feature_requests, [:story_source, :story_id, :id]
    add_index :feature_requests, [:requestor_id, :id]
    add_index :feature_requests, [:priority, :id]
    add_index :feature_requests, [:risk, :id]
    add_index :feature_requests, [:affected, :id]
    add_index :feature_requests, [:functional_area, :id]
    add_index :feature_requests, [:approver_id, :id]
    add_index :feature_requests, [:title, :id]

    # The following was mising from the indexing migration:
    add_index :defects, [:title, :id]
  end
  
  def self.down
    drop_table :feature_requests
  end
end
