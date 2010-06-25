class Release < ActiveRecord::Base
  attr_accessible :name, :code_freeze_on, :merge_on, :push_on, :description

  has_many :stories
  has_many :release_notes, :through => :stories
end
