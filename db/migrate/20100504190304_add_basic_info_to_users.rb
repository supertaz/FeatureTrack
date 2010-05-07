class AddBasicInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :home, :string
    add_column :users, :work, :string
    add_column :users, :mobile, :string
  end

  def self.down
    remove_column :users, :mobile
    remove_column :users, :work
    remove_column :users, :home
    remove_column :users, :lastname
    remove_column :users, :firstname
  end
end
