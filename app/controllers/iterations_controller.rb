class IterationsController < ApplicationController
  before_filter :require_user

  def index
    key_object = current_user.get_api_key('pivotal')
    PivotalTracker::Client.token = key_object.api_key
    projects = Project.find_by_source('pivotal')
    if projects.instance_of? Array
      @iterations = PivotalTracker::Iteration.all(projects.first)
    else
      @iterations = PivotalTracker::Iteration.all(projects)
    end
  end

  def current
    @default_refresh = 150
    @refresh = @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i

    @lanes = Hash.new
    key_object = current_user.get_api_key('pivotal')
    PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
    Project.active.each do |project|
      begin
        iteration = PivotalTracker::Iteration.current(project.get_source_project)
        iteration.stories.each do |story|
          unless story.labels.nil?
            found_lane = false
            labels = story.labels.split(',')
            labels.each_with_index do |label, i|
              unless label.match(/.+ lane/).nil?
                add_to_lane_hash(@lanes, label, story)
                found_lane = true
              else
                if !found_lane && i == (labels.count - 1)
                  add_to_lane_hash(@lanes, 'No lane assigned', story)
                end
              end
            end
          else
            add_to_lane_hash(@lanes, 'No lane assigned', story)
          end
        end
        @iteration_number = iteration.number
        @completion_date = iteration.finish.to_date
        @story_count = iteration.stories.count
      rescue => e
        if e.response.nil?
          flash.now[:error] = "Pivotal returned a #{e.type} exception.<br />Trying again in 15 seconds."
          @refresh = 15
        else
          flash.now[:error] = "Pivotal returned an exception: #{e.response}<br />Trying again in 15 seconds."
          @refresh = 15
        end
      end
    end
  end

  def assignments
    @default_refresh = 300
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @workers = Hash.new
    key_object = current_user.get_api_key('pivotal')
    PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
    Project.active.each do |project|
      iteration = PivotalTracker::Iteration.current(project.get_source_project)
      iteration.stories.each do |story|
        owner = (story.owned_by.nil? || story.owned_by.empty?) ? 'Unassigned' : story.owned_by
        add_to_lane_hash(@workers, owner, story)
      end
      @iteration_number = iteration.number
      @completion_date = iteration.finish.to_date
      @story_count = iteration.stories.count
    end
  end

  protected

  def add_to_lane_hash(lanes, label, story)
    unless lanes.has_key?(label)
      lanes[label] = Hash.new
      lanes[label]['name'] = label.capitalize
      lanes[label]['other'] = Array.new
      lanes[label]['features'] = Array.new
      lanes[label]['priority'] = Array.new
      lanes[label]['defects'] = Array.new
      lanes[label]['chores'] = Array.new
    end

    case story.story_type
      when 'feature'
        lanes[label]['features'] << story
      when 'bug'
        if get_defect_level(story) > 2
          lanes[label]['defects'] << story
        else
          lanes[label]['priority'] << story
        end
      when 'chore'
        lanes[label]['chores'] << story
      else
        lanes[label]['other'] << story
    end

  end
end
