class Project < ActiveRecord::Base
  attr_accessible :name, :source, :source_id, :allow_bugs, :allow_features, :allow_chores, :allow_releases, :active,
                  :archived, :test_project, :start_at, :end_at

  has_many :releases
  has_many :stories

  named_scope :active, :conditions => {:active => true, :test_project => false}
  named_scope :unarchived, :conditions => {:archived => false, :test_project => false}

  def get_source_project
    case self.source
      when 'pivotal'
        PivotalTracker::Project.find(self.source_id)
      when 'internal'
        self
    end
  end

  def allows_story_type?(story_type)
    case story_type
      when 'bug'
        self.allow_bugs?
      when 'feature'
        self.allow_features?
      when 'chore'
        self.allow_chores?
      when 'release'
        self.allow_releases?
      else
        false
    end
  end

  def self.move_story_to_project(story, project)
    if project.allows_story_type?(story.story_type)
      story.update({:project_id => project.get_source_project.id})
    else
      false
    end
  end

end
