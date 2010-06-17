class FeatureRequest < ActiveRecord::Base
  attr_accessible :status, :story_source, :story_id, :title, :requestor, :approver, :approved_at, :rejected_at,
                  :priority, :risk, :affected, :functional_area, :description, :project_id, :story_type

  belongs_to :requestor, :class_name => 'User'
  belongs_to :approver, :class_name => 'User'
  belongs_to :project

  has_and_belongs_to_many :stories

  validates_presence_of :status
  validates_presence_of :title
  validates_length_of :title, :within => 10..250
  validates_presence_of :requestor_id
  validates_presence_of :affected
  validates_presence_of :functional_area
  validates_presence_of :description
  validates_length_of :description, :minimum => 40

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
end
