class Environment < ActiveRecord::Base
  attr_accessible :name, :enable_at, :disable_at, :restricted_to, :description
end
