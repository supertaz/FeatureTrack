class Defect < ActiveRecord::Base
  attr_accessible :status, :story_source, :story_id, :title, :description, :reporter, :owner, :tester, :approver,
                  :approved_at, :rejected_at, :finished_at, :delivered_at, :started_at, :last_assigned_at, :severity,
                  :risk, :priority, :affected, :functional_area, :execution_priority, :environment, :project_id,
                  :reviewer, :story_type, :against_story_id

  belongs_to :reporter, :class_name => 'User'
  belongs_to :owner, :class_name => 'User'
  belongs_to :tester, :class_name => 'User'
  belongs_to :approver, :class_name => 'User'
  belongs_to :developer, :class_name => 'User'
  belongs_to :reviewer, :class_name => 'User'
  belongs_to :environment
  belongs_to :project

  validates_presence_of :status
  validates_presence_of :reporter
  validates_presence_of :affected
  validates_presence_of :functional_area
  validates_presence_of :severity
  validates_presence_of :title
  validates_length_of :title, :within => 6..255
  validates_presence_of :description
  validates_length_of :description, :minimum => 50
  validates_presence_of :environment

  def get_story_url
    unless self.project.nil?
      case self.story_source
        when 'pivotal'
          project = self.project.get_source_project
          story = project.stories.find(self.story_id)
          story.url
        else
          nil
      end
    else
      nil
    end
  end

  def calculate_execution_priority
    exec_pri = self.severity * 1000
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
      when 'Approved'
        exec_pri += 90000
      else
        exec_pri += 80000
    end
    exec_pri
  end

  def display_priority
    self.calculate_execution_priority.to_s[1,1]
  end

  def get_risk_level_string
    l = nil
    Defect.risk_levels.each do |level|
      if level[1] == self.risk
        l = level[0]
      end
    end
    l
  end

  def get_priority_string
    p = nil
    Defect.priorities.each do |pri|
      if pri[1] == self.priority
        p = pri[0]
      end
    end
    p
  end

  def get_severity_string
    s = nil
    Defect.severities.each do |sev|
      if sev[1] == self.severity
        s = sev[0]
      end
    end
    s
  end

  def self.affected_parties
    [
          'Sitters',
          'Parents',
          'Corporate parents',
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

end
