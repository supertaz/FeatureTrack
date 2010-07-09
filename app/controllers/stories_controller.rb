class StoriesController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_move_stories, :only => [:move]

  def index
    @project = Project.find(params[:project_id])
    stories = @project.stories.all
    @stories = Hash.new
    stories.each do |story|
      add_to_lane_hash(@stories, @project.name, story)
    end
  end

  def show
    @story = Story.find(params[:id])
    @note = Note.new(:story => @story)
  end

  def update_remote_status
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          story.update_attribute(:status, pivotal_story.current_state) if pivotal_story.current_state != story.status
        end
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to story_url(story)
  end

  def promote
    story = Story.find(params[:id])
    if current_user.developer || current_user.development_manager || current_user.scrum_master || current_user.global_admin
      unless story.project.nil?
        project = story.project.get_source_project
        new_story = project.stories.create(:name => story.title,
                                             :requested_by => (story.requestor.nickname.nil? || story.requestor.nickname.empty?) ? story.requestor.firstname : story.requestor.nickname,
                                             :description => story.description,
                                             :story_type => story.story_type,
                                             :other_id => story.id)
        if new_story.nil? || new_story.id.nil?
          flash[:error] = 'Unable to promote story'
          redirect_to story_url(story)
        else
          story.story_source = story.project.source
          story.source_url = story.url
          story.source_id = new_story.id
          story.approver = current_user
          story.approved_at = Time.zone.now
          story.reviewer = current_user
          story.reviewed_at = Time.zone.now
          story.status = 'Reviewed'
          story.save
          flash[:notice] = 'Story successfully promoted to pivotal.'
          redirect_to story_url(story)
        end
      else
        flash[:error] = 'Story needs to be assigned to a project before it can be promoted.'
        redirect_to story_url(story)
      end
    end
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
