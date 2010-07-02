class StoriesController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_move_stories, :only => [:move]

  def index
    @stories = Project.find(params[:project]).stories.all
  end

  def show
    @story = Story.find(params[:id])
    @note = Note.new(:story => @story)
  end

  def move
    case request.method
      when :get
        key_object = current_user.get_api_key('pivotal')
        unless key_object.nil?
          PivotalTracker::Client.token = key_object.api_key
          project = PivotalTracker::Project.find(params[:project_id])
          @story = project.stories.find(params[:story_id].to_i)
          @story.project_id = Project.find_by_source_id(params[:project_id]).id
          render 'project_options'
        end
      when :put
        key_object = current_user.get_api_key('pivotal')
        unless key_object.nil?
          PivotalTracker::Client.token = key_object.api_key
          project = PivotalTracker::Project.find(params[:project_id])
          @story = project.stories.find(params[:story_id].to_i)
          target_project = Project.find(params[:pivotal_tracker_story][:project_id])
          new_project = target_project.get_source_project
          if @story.update({:project_id => new_project.id})
            flash[:notice] = 'Story successfully moved'
          else
            flash[:error] = 'Unable to move story'
          end
          redirect_to root_url
        end
      else
        flash[:error] = 'Illegal request method: ' + request.method.to_s
        redirect_to root_url
    end
  end
end
