module DefectsHelper
  def get_severities
    Defect.severities
  end

  def get_risk_levels
    Defect.risk_levels
  end

  def get_priorities
    Defect.priorities
  end

  def get_affected_parties
    Defect.affected_parties
  end

  def get_functional_areas
    Defect.functional_areas
  end

  def get_active_projects
    Project.active
  end

  def get_allowable_statuses(defect, user)
    statuses = Array.new
    case defect.status
      when 'New'
        statuses << 'New'
        statuses << 'Reviewed' if user.scrum_master || user.global_admin
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
      when 'Reviewed'
        statuses << 'New' if user.scrum_master || user.global_admin
        statuses << 'Reviewed'
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'Prioritized'
        statuses << 'New' if user.scrum_master || user.global_admin
        statuses << 'Reviewed' if user.scrum_master || user.global_admin
        statuses << 'Prioritized'
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'In Dev'
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
        statuses << 'In Dev'
        statuses << 'In QA' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'In QA'
        statuses << 'In QA'
        statuses << 'In UAT' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Rejected' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Approved' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.scrum_master || user.global_admin
      when 'In UAT'
        statuses << 'In UAT'
        statuses << 'Rejected' if user.qa || user.qa_manager || user.business_user || user.scrum_master || user.global_admin
        statuses << 'Approved' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.business_user || user.scrum_master || user.global_admin
      when 'Rejected'
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
        statuses << 'In QA' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Rejected'
        statuses << 'Approved' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.business_user || user.scrum_master || user.global_admin
      when 'Approved'
        statuses << 'Approved'
        statuses << 'Rejected' if user.qa || user.qa_manager || user.business_user || user.scrum_master || user.global_admin
    end
    statuses
  end
end
