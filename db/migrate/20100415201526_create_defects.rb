class CreateDefects < ActiveRecord::Migration
  def self.up
    create_table :defects do |t|
      t.string :status
      t.string :story_source
      t.integer :story_id
      t.string :title
      t.integer :reporter_id
      t.integer :owner_id
      t.integer :tester_id
      t.integer :approver_id
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :finished_at
      t.datetime :delivered_at
      t.datetime :started_at
      t.datetime :last_assigned_at
      t.timestamps
      t.text :description
    end
  end

  def self.down
    drop_table :defects
  end
end
