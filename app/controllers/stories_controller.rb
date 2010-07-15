class StoriesController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_move_stories, :only => [:move]

  def index
    @project = Project.find(params[:project_id])
    stories = @project.stories.all
    @stories = Hash.new
    @statuses = Hash.new
    stories.each do |story|
      add_to_lane_hash(@stories, @project.name, story)
      add_to_lane_hash(@statuses, @template.get_state_name(story.status), story)
    end
  end

  def show
    @story = Story.find(params[:id])
    @note = Note.new(:story => @story)
  end

  def update_remote_status
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty? || story.story_source != 'pivotal'
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          story.status = pivotal_story.current_state if pivotal_story.current_state != story.status
          story.estimated_points = pivotal_story.estimate if pivotal_story.estimate != story.estimated_points
          if story.source_url.nil? && !story.source_id.nil?
            story_url = pivotal_project.use_https? ? 'https://www.pivotaltracker.com/story/show/' : 'http://www.pivotaltracker.com/story/show/'
            story.source_url = story_url + story.source_id
          end
          user = User.find_by_nickname(pivotal_story.owned_by)
          story.assignee = user unless user.nil?
          story.save if story.changed?
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
                                             :other_id => story.id,
                                             :integration_id => story.project.external_integration_id)
        if new_story.nil? || new_story.id.nil?
          flash[:error] = 'Unable to promote story'
          redirect_to story_url(story)
        else
          unless story.story_source.nil? || story.story_source != 'pivotal'
            begin
              pivotal_project = story.project.get_source_project
              pivotal_story = pivotal_project.stories.find(story.source_id)
              story.notes.each do |note|
                if note.subject.empty?
                  note_header = "*#{note.author.fullname} said:*\n\n"
                else
                  note_header = "**#{note.author.fullname} talked about \"#{note.subject}\":**\n\n"
                end
                pivotal_story.notes.create(:text => note_header + note.body)
              end
            rescue => e
              backtrace = String.new
              e.backtrace.each do |msg|
                backtrace += "#{msg}\n"
              end
              logger.error backtrace
              if e.respond_to? 'response'
                if e.response.nil?
                  error_message += "#{e.class} exception#{e.respond_to?('message') ? ':' + e.message : '.'}"
                else
                  error_message += "Remote source exception: #{e.response}"
                end
              else
                error_message += "#{e.class} exception#{e.respond_to?('message') ? ':' + e.message : '.'}"
              end
              flash[:error] = "Unable to copy notes to pivotal: #{error_message}"
            end
          end
          story.story_source = story.project.source
          story.source_url = (project.use_https ? 'https' : 'http') + '://www.pivotaltracker.com/story/show/' + new_story.id.to_s
          story.source_id = new_story.id
          story.approver = current_user
          story.approved_at = Time.zone.now
          story.reviewer = current_user
          story.reviewed_at = Time.zone.now
          story.status = 'Reviewed' if story.story_type == 'bug'
          story.status = 'Approved' unless story.story_type == 'bug'
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

  def start
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          pivotal_story.update(:current_state => 'started') if pivotal_story.current_state != 'started'
          story.update_attribute(:status, 'started') if pivotal_story.current_state == 'started'
        end
      else
        story.status = 'In Dev'
        story.save
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

  def qa
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          pivotal_story.update(:current_state => 'finished') if pivotal_story.current_state != 'finished'
          story.update_attribute(:status, 'finished') if pivotal_story.current_state == 'finished'
        end
      else
        story.status = 'In QA'
        story.save
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

  def uat
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          pivotal_story.update(:current_state => 'delivered') if pivotal_story.current_state != 'delivered'
          story.update_attribute(:status, 'delivered') if pivotal_story.current_state == 'delivered'
        end
      else
        story.status = 'In UAT'
        story.save
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

  def accept
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          pivotal_story.update(:current_state => 'accepted') if pivotal_story.current_state != 'accepted'
          story.update_attribute(:status, 'accepted') if pivotal_story.current_state == 'accepted'
        end
      else
        story.status = 'Accepted'
        story.save
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

  def reject
    story = Story.find(params[:id])
    begin
      unless story.story_source.nil? || story.story_source.empty?
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        unless pivotal_story.nil?
          pivotal_story.update(:current_state => 'rejected') if pivotal_story.current_state != 'rejected'
          story.update_attribute(:status, 'rejected') if pivotal_story.current_state == 'rejected'
        end
      else
        story.status = 'Rejected'
        story.save
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
