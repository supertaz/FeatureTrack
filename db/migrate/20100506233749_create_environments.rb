class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.string :name
      t.datetime :enable_at
      t.datetime :disable_at
      t.string :restricted_to
      t.text :description
      t.timestamps
    end
  end
  
  def self.down
    drop_table :environments
  end
end
