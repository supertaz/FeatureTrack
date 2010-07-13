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
      when 'unscheduled', 'to be scheduled'
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
      when 'delivered', 'in uat'
        '/images/icons/UAT.png'
      when 'finished', 'in qa'
        '/images/icons/QA.png'
      when 'started', 'in dev'
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

  def get_linked_story_uri(story)
    unless story.against_story_source.nil?
      case story.against_story_source
        when 'internal'
          story_url(Story.find(story.against_story_id))
        when 'pivotal'
          story_url(Story.find_by_source_id(story.against_story_id))
      end
    end
  end

  def get_linked_story_link(story)
    linked_story = nil
    unless story.against_story_source.nil?
      case story.against_story_source
        when 'internal'
          linked_story = Story.find(story.against_story_id)
        when 'pivotal'
          linked_story = Story.find_by_source_id(story.against_story_id)
      end
    end
    create_story_link(linked_story)
  end

  def create_story_link(story = nil)
    unless story.nil?
      link_text = "#{image_tag get_state_icon(story.status)}&nbsp;<i>#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}"
      link_to link_text, story_url(story)
    else
      nil
    end
  end

  def get_linked_story_source_name(story)
    unless story.against_story_source.nil? || story.against_story_source.empty?
      case story.against_story_source
        when 'internal'
          'FeatureTrack'
        else
          story.against_story_source.capitalize
      end
    else
      'FeatureTrack'
    end
  end
end
