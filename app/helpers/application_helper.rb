# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_story_state(state, image_tag = nil)
    case state.downcase
      when 'accepted'
        "<div class = 'accepted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'rejected'
        "<div class = 'rejected'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'delivered', 'in uat'
        "<div class = 'delivered'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'finished', 'in qa'
        "<div class = 'finished'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'started', 'in dev'
        "<div class = 'started'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'unstarted', 'not started'
        "<div class = 'unstarted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      else
        "<div class = 'unstarted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
    end
  end

  def get_state_step(state)
    case state.downcase
      when 'accepted'
        25
      when 'rejected'
        12
      when 'delivered', 'in uat'
        20
      when 'finished', 'in qa'
        15
      when 'started', 'in dev'
        10
      when 'unstarted', 'not started'
        8
      when 'unscheduled'
        6
      when 'approved'
        4
      when 'reviewed'
        2
      else
        0
    end
  end

  def sort_defect_score(story_a, story_b)
    get_defect_priority(story_b) <=> get_defect_priority(story_a)
  end

  def get_defect_priority(story)
    story.execution_priority || 9
  end

  def get_state_icon(state)
    case state.downcase
      when 'accepted'
        '/images/icons/accepted.png'
      when 'rejected'
        '/images/icons/rejected.png'
      when 'delivered'
        '/images/icons/UAT.png'
      when 'finished'
        '/images/icons/QA.png'
      when 'started'
        '/images/icons/dev.png'
      else
        '/images/icons/unstarted.png'
    end
  end

  def get_state_name(state)
    case state.downcase
      when 'accepted'
        'Accepted'
      when 'rejected'
        'Rejected'
      when 'delivered'
        'In UAT'
      when 'finished'
        'In QA'
      when 'started'
        'In Dev'
      when 'unstarted'
        'Not Started'
      when 'reviewed'
        'Reviewed'
      when 'approved'
        'Approved'
      when 'prioritized'
        'Prioritized'
      when 'unscheduled'
        'To Be Scheduled'
      when 'new'
        'New'
      else
        state
    end
  end

  def get_task_type_icon(task_type)
    case task_type.downcase
      when 'chore'
        '/images/icons/chore.png'
      when 'bug'
        '/images/icons/bug.png'
      when 'feature'
        '/images/icons/feature.png'
      when 'release'
        '/images/icons/release.png'
    end
  end

  def get_statuses
    Story.statuses
  end

  def get_severities
    Story.severities
  end

  def get_risk_levels
    Story.risk_levels
  end

  def get_priorities
    Story.priorities
  end

  def get_affected_parties
    Story.affected_parties
  end

  def get_functional_areas
    Story.functional_areas
  end

  def get_active_projects
    Project.active
  end

  def get_unarchived_projects
    Project.unarchived
  end

end
