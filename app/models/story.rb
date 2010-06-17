class Story < ActiveRecord::Base
  belongs_to :project
  belongs_to :owner, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'

  has_many :notes

  has_and_belongs_to_many :defects
  has_and_belongs_to_many :feature_requests
end
