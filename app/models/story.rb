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
  belongs_to :reported_against, :class_name => 'Story'
  belongs_to :story, :counter_cache => :linked_story_count

  has_many :notes
  has_many :defects, :class_name => 'Story', :foreign_key => 'against_story_id'

  has_and_belongs_to_many :release_notes

  before_save :manage_points

  named_scope :bugs, :conditions => {:story_type => 'bug'}
  named_scope :features, :conditions => {:story_type => 'feature'}
  named_scope :accepted, :conditions => {:status => 'accepted'}
  named_scope :closed, :conditions => {:status => 'closed'}
  named_scope :open, :conditions => ["status NOT IN ('accepted','closed')"]
  named_scope :resolved, :conditions => ["status IN ('accepted','closed')"]
  named_scope :project, lambda { |project|
          { :conditions => {:project_id => project.id} }
  }
  named_scope :project_id, lambda { |project_id|
          { :conditions => {:project_id => project_id } }
  }

  validates_presence_of :status
  validates_presence_of :requestor
#  validates_presence_of :affected, :if => :story_type == 'bug'
#  validates_presence_of :functional_area
#  validates_presence_of :severity
#  validates_presence_of :environment
  validates_presence_of :title
  validates_length_of :title, :within => 6..255
  validates_presence_of :description
  validates_length_of :description, :minimum => 50

  def calculate_execution_priority
    unless self.severity.nil?
      exec_pri = self.severity * 1000
    else
      exec_pri = 1000
    end
    unless self.priority.nil?
      if self.priority.between?(1, 4)
        if exec_pri > 1999
          exec_pri = 1000 + (self.priority * 90)
        else
          exec_pri += (self.priority * 90)
        end
      elsif self.priority.between?(5, 6)
        if exec_pri > 2999
          exec_pri = 2000 + (self.priority * 90)
        else
          exec_pri += (self.priority * 90)
        end
      else
        exec_pri += (self.priority * 90)
      end
    end
    unless self.risk.nil?
      exec_pri += (self.risk * 20)
    end
    case self.status
      when 'New'
        exec_pri += 10000
      when 'Reviewed'
        exec_pri += 20000
      when 'Prioritized'
        exec_pri += 30000
      when 'Rejected'
        exec_pri += 40000
      when 'In Dev'
        exec_pri += 50000
      when 'In QA'
        exec_pri += 60000
      when 'In UAT'
        exec_pri += 70000
      when 'Approved'
        exec_pri += 90000
      else
        exec_pri += 80000
    end
    exec_pri
  end

  def display_priority
    self.calculate_execution_priority.to_s.rjust(5, '0')[1,1]
  end

  def get_risk_level_string
    l = nil
    Story.risk_levels.each do |level|
      if level[1] == self.risk
        l = level[0]
      end
    end
    l
  end

  def get_priority_string
    p = nil
    Story.priorities.each do |pri|
      if pri[1] == self.priority
        p = pri[0]
      end
    end
    p
  end

  def get_severity_string
    s = nil
    Story.severities.each do |sev|
      if sev[1] == self.severity
        s = sev[0]
      end
    end
    s
  end

  def self.statuses
    [
          ['New'],
          ['Reviewed'],
          ['Approved'],
          ['To Be Scheduled', 'unscheduled'],
          ['Prioritized'],
          ['In Dev', 'started'],
          ['In QA', 'finished'],
          ['In UAT', 'delivered'],
          ['Rejected'],
          ['Accepted']
    ]
  end

  def self.affected_parties
    [
          'Sitters',
          'Parents',
          'Corporate parents',
          'Free trial parents',
          'Customer support',
          'Administrators',
          'External',
          'Everybody'
    ]
  end

  def self.functional_areas
    [
          'Home page',
          'External pages',
          'Registration',
          'Payment',
          'My Sittercity',
          'Account management',
          'Parent profile',
          'Sitter profile',
          'Background check',
          'Messaging',
          'Reinstatement',
          'Job posting',
          'Sitter search',
          'Job search',
          'Job response',
          'Job feeds',
          'Other'
    ]
  end

  def self.severities
    [
          ['Site is down', 1],
          ['Major functionality not working', 2],
          ['Minor functionality not working', 3],
          ['Major cosmetic flaw', 4],
          ['Minor cosmetic flaw', 5],
          ['Unable to replicate', 9]
    ]
  end

  def self.risk_levels
    [
          ['Could take site down', 1],
          ['Could break major functionality', 2],
          ['Could break minor functionality', 3],
          ['Could create cosmetic flaws', 4],
          ['No appreciable risk', 9]
    ]
  end

  def self.priorities
    [
          ['Current revenue loss (major)', 1],
          ['Current revenue loss (minor)', 2],
          ['Missed revenue opportunity (major)', 3],
          ['Missed revenue opportunity (minor)', 4],
          ['Potential missed revenue', 5],
          ['Negative brand impact', 6],
          ['Desirable feature', 7],
          ['Desirable cosmetics', 8]
    ]
  end

  protected

    def set_execution_priority
      self.execution_priority = self.display_priority.to_i
    end

    def manage_points
      unless self.estimated_points.nil?
        self.original_points = self.estimated_points if self.original_points.nil?
      end
    end
end
