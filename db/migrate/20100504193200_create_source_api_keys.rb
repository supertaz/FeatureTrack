class CreateSourceApiKeys < ActiveRecord::Migration
  def self.up
    create_table :source_api_keys do |t|
      t.integer :user_id
      t.string :source
      t.string :api_key

      t.timestamps
    end
  end

  def self.down
    drop_table :source_api_keys
  end
end
