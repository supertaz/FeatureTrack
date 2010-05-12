class Defect < ActiveRecord::Base
  attr_accessible :status, :story_source, :story_id, :title, :description, :reporter, :owner, :tester, :approver,
                  :approved_at, :rejected_at, :finished_at, :delivered_at, :started_at, :last_assigned_at, :severity,
                  :risk, :priority, :affected, :functional_area, :execution_priority, :environment, :project

  belongs_to :reporter, :class_name => 'User'
  belongs_to :owner, :class_name => 'User'
  belongs_to :tester, :class_name => 'User'
  belongs_to :approver, :class_name => 'User'
  belongs_to :developer, :class_name => 'User'
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

  def self.affected_parties
    [
          'Sitters',
          'Parents',
          'Corporate parents',
          'Customer support',
          'Administrators',
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
          ['Could create cosmetic flaws', 4]
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
