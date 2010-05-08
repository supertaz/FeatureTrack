class Environment < ActiveRecord::Base
  attr_accessible :name, :enable_at, :disable_at, :restricted_to, :description

  validates_presence_of :name
  validates_length_of :name, :minimum => 2
  validates_presence_of :description
  validates_length_of :description, :minimum => 20
end
