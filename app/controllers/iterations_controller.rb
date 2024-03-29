class IterationsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_stories

  def index
    projects = Project.find_by_source('pivotal')
    begin
      if projects.instance_of? Array
        @iterations = PivotalTracker::Iteration.all(projects.first)
      else
        @iterations = PivotalTracker::Iteration.all(projects)
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception, trying again in 15 seconds."
        @refresh = 15
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}&nbsp;&nbsp;Will try again in 15 seconds."
        @refresh = 15
      end
    end
  end

  def current
    @default_refresh = 150
    @refresh = @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @lanes = Hash.new
    Project.active.each do |project|
      project.stories.each do |story|
        add_to_lane_hash(@lanes, project.name, story)
      end
    end
  end

  def assignments
    @default_refresh = 300
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @workers = Hash.new
    Project.active.each do |project|
      project.stories.each do |story|
        owner = story.assignee.fullname unless story.assignee.nil?
        owner ||= story.owner.fullname unless story.owner.nil?
        owner ||= 'Unassigned'
        add_to_lane_hash(@workers, owner, story)
      end
    end
  end

  def orphans
    @default_refresh = 300
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @lanes = Hash.new
    Story.all(:conditions => {:project_id => nil}).each do |orphan|
      add_to_lane_hash(@lanes, 'No Project', orphan)
    end
  end
end
