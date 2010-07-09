class AddExternalIntegrationIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :external_integration_id, :integer
  end

  def self.down
    remove_column :projects, :external_integration_id
  end
end
