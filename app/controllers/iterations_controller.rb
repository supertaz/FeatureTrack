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

end
