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
    @notes = @story.notes
    @attachments = @story.attached_files
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
          if story.source_url.nil? && !story.source_id.nil? && !pivotal_project.nil?
            story_url = pivotal_project.use_https ? 'https://www.pivotaltracker.com/story/show/' : 'http://www.pivotaltracker.com/story/show/'
            story.source_url = story_url + story.source_id.to_s
          end
          user = User.find_by_nickname(pivotal_story.owned_by)
          story.assignee = user unless user.nil?
          story.save if story.changed?
        end
      end
    rescue => e
      if e.respond_to?(:response)
        if e.response.nil?
          flash.now[:error] = "#{e.class} exception received."
        else
          flash.now[:error] = "Remote source returned an exception: #{e.response}"
        end
      else
        backtrace = "Exception encountered: #{e.message}\n"
        e.backtrace.each do |msg|
          backtrace += "#{msg}\n"
        end
        logger.error backtrace
      end
    end
    redirect_to story_url(story)
  end

  def attach_file
    @story = Story.find(params[:id])
    @story.attached_files
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
          redirect_to request.referer
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
        flash[:notice] = "Started \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      else
        story.status = 'In Dev'
        story.save
        flash[:notice] = "Started \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to request.referer
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
        flash[:notice] = "Moved \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\" to QA"
      else
        story.status = 'In QA'
        flash[:notice] = "Moved \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\" to QA"
        story.save
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to request.referer
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
        flash[:notice] = "Moved \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\" to UAT"
      else
        story.status = 'In UAT'
        story.save
        flash[:notice] = "Moved \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\" to UAT"
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to request.referer
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
        flash[:notice] = "Accepted \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      else
        story.status = 'Accepted'
        story.save
        flash[:notice] = "Accepted \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to request.referer
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
        flash[:notice] = "Rejected \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      else
        story.status = 'Rejected'
        story.save
        flash[:notice] = "Rejected \"#{story.project.nil? ? 'Unassigned' : story.project.name}</i> #{story.story_type.upcase} \##{story.id}: #{story.title}\""
      end
    rescue => e
      if e.response.nil?
        flash.now[:error] = "#{e.class} exception received."
      else
        flash.now[:error] = "Remote source returned an exception: #{e.response}"
      end
    end
    redirect_to request.referer
  end

  def move
    case request.method
      when :get
        project = Project.find(params[:project_id])
        @story = project.stories.find(params[:story_id].to_i)
        render 'project_options'
      when :put
          project = Project.find(params[:project_id])
          @story = project.stories.find(params[:story_id].to_i)
          target_project = Project.find(params[:story][:project_id])
          success = false
          case @story.story_source
            when 'pivotal'
              pivotal_project = project.get_source_project
              pivotal_story = pivotal_project.stories.find(@story.source_id)
              case target_project.source
                when 'pivotal'
                  if pivotal_story.move_to_project(target_project.source_id)
                    success = true
                  end
                when 'internal'
                  if pivotal_story.delete
                    success = true
                  end
              end
            when 'internal'
              case target_project.source
                when 'pivotal'
                  @story.status = 'New'
                  success = true
                when 'internal'
                  success = true
              end
          end
          if success
            @story.project = target_project
            @story.save
            flash[:notice] = 'Story successfully moved'
          else
            flash[:error] = 'Unable to move story'
          end
          redirect_to @story
      else
        flash[:error] = 'Illegal request method: ' + request.method.to_s
        redirect_to @story
    end
  end
end
