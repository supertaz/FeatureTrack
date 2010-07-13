module DefectsHelper
  def get_allowable_statuses(defect, user)
    statuses = Array.new
    case defect.status.downcase
      when 'new'
        statuses << 'New'
        statuses << 'Reviewed' if user.scrum_master || user.global_admin
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
      when 'reviewed'
        statuses << 'New' if user.scrum_master || user.global_admin
        statuses << 'Reviewed'
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'prioritized'
        statuses << 'New' if user.scrum_master || user.global_admin
        statuses << 'Reviewed' if user.scrum_master || user.global_admin
        statuses << 'Prioritized'
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'to be scheduled', 'unscheduled', 'approved', 'unstarted'
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
        statuses << 'In Dev'
        statuses << 'In QA' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'in dev'
        statuses << 'Prioritized' if user.scrum_master || user.business_user || user.global_admin
        statuses << 'In Dev'
        statuses << 'In QA' if user.developer || user.development_manager || user.scrum_master || user.global_admin
      when 'in qa'
        statuses << 'In QA'
        statuses << 'In UAT' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Rejected' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Accepted' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.scrum_master || user.global_admin
      when 'in uat'
        statuses << 'In UAT'
        statuses << 'Rejected' if user.qa || user.qa_manager || user.business_user || user.scrum_master || user.global_admin
        statuses << 'Accepted' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.business_user || user.scrum_master || user.global_admin
      when 'rejected'
        statuses << 'In Dev' if user.developer || user.development_manager || user.scrum_master || user.global_admin
        statuses << 'In QA' if user.qa || user.qa_manager || user.scrum_master || user.global_admin
        statuses << 'Rejected'
        statuses << 'Accepted' if ((user.qa || user.qa_manager) && (defect.priority.nil? || defect.priority.empty?)) || user.business_user || user.scrum_master || user.global_admin
      when 'accepted'
        statuses << 'Accepted'
        statuses << 'Rejected' if user.qa || user.qa_manager || user.business_user || user.scrum_master || user.global_admin
    end
    statuses
  end
end
