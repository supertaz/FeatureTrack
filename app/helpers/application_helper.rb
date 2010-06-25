# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_story_state(state, image_tag = nil)
    case state.downcase
      when 'accepted'
        "<div class = 'accepted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'rejected'
        "<div class = 'rejected'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'delivered'
        "<div class = 'delivered'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'finished'
        "<div class = 'finished'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'started'
        "<div class = 'started'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      when 'unstarted'
        "<div class = 'unstarted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
      else
        "<div class = 'unstarted'>#{image_tag.nil? ? '' : image_tag}#{get_state_name(state)}</div>"
    end
  end

  def get_state_step(state)
    case state
      when 'accepted'
        25
      when 'rejected'
        5
      when 'delivered'
        20
      when 'finished'
        15
      when 'started'
        10
      else
        0
    end
  end

  def sort_defect_score(defect_a, defect_b)
    get_defect_priority(defect_b) <=> get_defect_priority(defect_a)
  end

  def get_defect_priority(defect)
    pri = 1000
    unless defect.labels.nil?
      defect.labels.split(',').each do |label|
        if label.match(/^p[0-9]$/)
          unless label.gsub(/^p([0-9])$/, '\1').nil? || get_state_step(defect.current_state).nil?
            pri = (6000 - (label.gsub(/p([0-9])/, '\1').to_i * 1000)) + get_state_step(defect.current_state)
          end
        end
      end
    end
    pri
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
      when 'prioritized'
        'Prioritized'
      when 'unscheduled', 'approved'
        'To Be Scheduled'
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
