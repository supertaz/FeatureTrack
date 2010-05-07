# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_story_state(state, image_tag = nil)
    case state
      when 'accepted'
        "<div class = 'accepted'>#{image_tag.nil? ? '' : image_tag}ACCEPTED</div>"
      when 'rejected'
        "<div class = 'rejected'>#{image_tag.nil? ? '' : image_tag}REJECTED</div>"
      when 'delivered'
        "<div class = 'delivered'>#{image_tag.nil? ? '' : image_tag}In UAT</div>"
      when 'finished'
        "<div class = 'finished'>#{image_tag.nil? ? '' : image_tag}In QA</div>"
      when 'started'
        "<div class = 'started'>#{image_tag.nil? ? '' : image_tag}In Dev</div>"
      when 'unstarted'
        "<div class = 'unstarted'>#{image_tag.nil? ? '' : image_tag}Not Started</div>"
      else
        "<div class = 'rejected'>??? Unknown ???</div>"
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
      when 'unstarted'
        0
    end
  end

  def sort_defect_score(defect_a, defect_b)
    get_defect_priority(defect_b) <=> get_defect_priority(defect_a)
  end

  def get_defect_priority(defect)
    pri = 1000
    defect.labels.split(',').each do |label|
      if label.match(/^p[0-9]$/)
        unless label.gsub(/^p([0-9])$/, '\1').nil? || get_state_step(defect.current_state).nil?
          pri = (6000 - (label.gsub(/p([0-9])/, '\1').to_i * 1000)) + get_state_step(defect.current_state)
        end
      end
    end
    pri
  end

  def get_schedule_week(story)
    start, finish = nil
    unless story.labels.nil?
      story.labels.split(',').each do |label|
        if label.match(/^w[0-9]+(-?[0-9]+){1}$/)
          start, finish = label.gsub(/^w([0-9]+)(-?([0-9]+)){1}$/, '\1,\3').split(',')
        elsif label.match(/^w[0-9]+$/)
          start = label.gsub(/^w([0-9]+)$/, '\1')
        end
      end
    end
    [start, finish]
  end

  def get_state_icon(state)
    case state
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
      when 'unstarted'
        '/images/icons/unstarted.png'
    end
  end

  def get_task_type_icon(task_type)
    case task_type
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

end
