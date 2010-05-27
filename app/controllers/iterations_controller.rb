class IterationsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_stories

  def index
    key_object = current_user.get_api_key('pivotal')
    unless key_object.nil?
      PivotalTracker::Client.token = key_object.api_key
      projects = Project.find_by_source('pivotal')
      begin
        if projects.instance_of? Array
          @iterations = PivotalTracker::Iteration.all(projects.first)
        else
          @iterations = PivotalTracker::Iteration.all(projects)
        end
      rescue => e
        if e.response.nil?
          flash.now[:error] = "#{e.type} exception, trying again in 15 seconds."
          @refresh = 15
        else
          flash.now[:error] = "Remote source returned an exception: #{e.response}&nbsp;&nbsp;Will try again in 15 seconds."
          @refresh = 15
        end
      end
    else
      flash[:error] = "You don't have a pivotal API key."
      redirect_to dashboard_url
    end
  end

  def current
    @default_refresh = 150
    @refresh = @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @lanes = Hash.new
    key_object = current_user.get_api_key('pivotal')
    unless key_object.nil?
      PivotalTracker::Client.token = key_object.api_key
      Project.active.each do |project|
        begin
          iteration = PivotalTracker::Iteration.current(project.get_source_project)
          iteration.stories.each do |story|
            add_to_lane_hash(@lanes, project.name, story)
          end
        rescue => e
          if !(defined? e.response) || e.response.nil?
            flash.now[:error] = "#{e.type} exception, trying again in 15 seconds."
            @refresh = 15
          else
            flash.now[:error] = "Remote source returned an exception: #{e.response}&nbsp;&nbsp;Will try again in 15 seconds."
            @refresh = 15
          end
        end
      end
    else
      flash[:error] = "You don't have a pivotal API key."
      redirect_to dashboard_url
    end
  end

  def assignments
    @default_refresh = 300
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @workers = Hash.new
    key_object = current_user.get_api_key('pivotal')
    unless key_object.nil?
      PivotalTracker::Client.token = key_object.api_key
      Project.active.each do |project|
        begin
          iteration = PivotalTracker::Iteration.current(project.get_source_project)
          iteration.stories.each do |story|
            owner = (story.owned_by.nil? || story.owned_by.empty?) ? 'Unassigned' : story.owned_by
            add_to_lane_hash(@workers, owner, story)
          end
        rescue => e
          if !(defined? e.response) || e.response.nil?
            flash.now[:error] = "#{e.type} exception, trying again in 15 seconds."
            @refresh = 15
          else
            flash.now[:error] = "Remote source returned an exception: #{e.response}&nbsp;&nbsp;Will try again in 15 seconds."
            @refresh = 15
          end
        end
      end
    else
      flash[:error] = "You don't have a pivotal API key."
      redirect_to dashboard_url
    end
  end

  protected

  def add_to_lane_hash(lanes, label, story, accepted_bubble_up = true)
    unless lanes.has_key?(label)
      lanes[label] = Hash.new
      lanes[label]['name'] = label.capitalize
      lanes[label]['total_items'] = 0
      lanes[label]['total_features'] = 0
      lanes[label]['total_defects'] = 0
      lanes[label]['total_chores'] = 0
      lanes[label]['total_others'] = 0
      lanes[label]['open_items'] = 0
      lanes[label]['open_features'] = 0
      lanes[label]['open_defects'] = 0
      lanes[label]['open_chores'] = 0
      lanes[label]['open_others'] = 0
      accepted_other = Array.new
      accepted_features = Array.new
      accepted_priority = Array.new
      accepted_defects = Array.new
      accepted_chores = Array.new
      todo_other = Array.new
      todo_features = Array.new
      todo_priority = Array.new
      todo_defects = Array.new
      todo_chores = Array.new
      lanes[label]['accepted'] = {'other' => accepted_other,
                                  'features' => accepted_features,
                                  'priority' => accepted_priority,
                                  'defects' => accepted_defects,
                                  'chores' => accepted_chores
      }
      lanes[label]['todo'] = {    'other' => todo_other,
                                  'features' => todo_features,
                                  'priority' => todo_priority,
                                  'defects' => todo_defects,
                                  'chores' => todo_chores
      }
    end

    if accepted_bubble_up && story.current_state == 'accepted'
      target = lanes[label]['accepted']
    else
      target = lanes[label]['todo']
    end
    lanes[label]['total_items'] += 1
    lanes[label]['open_items'] += 1 unless story.current_state == 'accepted'
    case story.story_type
      when 'feature'
        target['features'] << story
        lanes[label]['total_features'] += 1
        lanes[label]['open_features'] += 1 unless story.current_state == 'accepted'
      when 'bug'
        if get_defect_level(story) > 2
          target['defects'] << story
        else
          target['priority'] << story
        end
        lanes[label]['total_defects'] += 1
        lanes[label]['open_defects'] += 1 unless story.current_state == 'accepted'
      when 'chore'
        target['chores'] << story
        lanes[label]['total_chores'] += 1
        lanes[label]['open_chores'] += 1 unless story.current_state == 'accepted'
      else
        target['other'] << story
        lanes[label]['total_others'] += 1
        lanes[label]['open_others'] += 1 unless story.current_state == 'accepted'
    end

  end
end
