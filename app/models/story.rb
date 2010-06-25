class Story < ActiveRecord::Base
  belongs_to :project
  belongs_to :owner, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'
  belongs_to :release
  belongs_to :requestor, :class_name => 'User'
  belongs_to :tester, :class_name => 'User'
  belongs_to :approver, :class_name => 'User'
  belongs_to :developer, :class_name => 'User'
  belongs_to :reviewer, :class_name => 'User'
  belongs_to :environment

  has_many :notes

  has_and_belongs_to_many :release_notes

  named_scope :bugs, :conditions => {:story_type => 'bug'}
  named_scope :features, :conditions => {:story_type => 'feature'}
  named_scope :project, lambda { |project|
          { :conditions => {:project_id => project.id} }
  }
  named_scope :project_id, lambda { |project_id|
          { :conditions => {:project_id => project_id } }
  }
end
