class FeatureRequest < ActiveRecord::Base
  attr_accessible :status, :story_source, :story_id, :title, :requestor_id, :approver_id, :approved_at, :rejected_at, :priority, :risk, :affected, :functional_area, :description
end
