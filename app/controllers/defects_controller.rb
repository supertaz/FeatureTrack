class DefectsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_defects, :except => [:new, :create]
  before_filter :current_user_can_create_defects, :only => [:new, :create]

  def index
    @search = Defect.search(params[:search])
#    @defects = Defect.all.sort {|a,b| a.calculate_execution_priority <=> b.calculate_execution_priority}
    @defects = @search.all
  end

  def show
    key_object = current_user.get_api_key('pivotal')
    PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
    @defect = Defect.find(params[:id])
    markdown = RDiscount.new(@defect.description)
    @defect_description = Sanitize.clean(markdown.to_html, Sanitize::Config::BASIC)
  end

  def new
    @defect = Defect.new
  end

  def create
    @defect = Defect.new(params[:defect])
    @defect.status = 'New'
    @defect.reporter = current_user
    @defect.environment = Environment.find(params[:defect].delete('environment_id'))
    unless @defect.project.nil? || @defect.project.blank?
      unless @defect.against_story_id.nil? || @defect.against_story_id.blank?
        @defect.against_story_source = @defect.project.source
      end
    end
    if @defect.save
      flash[:notice] = "Successfully created defect."
      redirect_to @defect
    else
      render :action => 'new'
    end
  end

  def edit
    @defect = Defect.find(params[:id])
  end

  def update
    @defect = Defect.find(params[:id])
    @defect.environment = Environment.find(params[:defect].delete('environment_id'))
    unless @defect.project.nil? || @defect.project.blank?
      unless @defect.against_story_id.nil? || @defect.against_story_id.blank?
        @defect.against_story_source = @defect.project.source
      end
    end
    if @defect.description != params[:defect]['description']
      description_changed = true
    else
      description_changed = false
    end
    if @defect.update_attributes(params[:defect])
      unless @defect.project.nil? || @defect.story_id.nil?
        if description_changed
          key_object = current_user.get_api_key('pivotal')
          PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
          project = @defect.project.get_source_project
          story = project.stories.find(@defect.story_id)
          story.update({'description' => @defect.description})
        end
      end
      flash[:notice] = "Successfully updated defect."
      redirect_to @defect
    else
      render :action => 'edit'
    end
  end

  def destroy
    @defect = Defect.find(params[:id])
    @defect.destroy
    flash[:notice] = "Successfully destroyed defect."
    redirect_to defects_url
  end

  def promote
    defect = Defect.find(params[:id])
    if (current_user.developer && defect.display_priority.to_i <= 3) || current_user.development_manager || current_user.scrum_master || current_user.global_admin
      unless defect.project.nil?
        unless defect.against_story_id.nil? || defect.against_story_id.blank?
          defect.against_story_source = defect.project.source
        end
        key_object = current_user.get_api_key('pivotal')
        PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
        project = defect.project.get_source_project
        new_defect = project.stories.create(:name => "P#{defect.display_priority} - " + defect.title,
                                             :labels => "p#{defect.display_priority}",
                                             :requested_by => (defect.reporter.nickname.nil? || defect.reporter.nickname.empty?) ? defect.reporter.firstname : defect.reporter.nickname,
                                             :description => defect.description,
                                             :story_type => defect.story_type.nil? ? 'bug' : defect.story_type)
        if new_defect.nil? || new_defect.id.nil?
        defect.story_source = defect.project.source
        defect.story_id = new_defect.id
        defect.reviewer = current_user
        defect.reviewed_at = Time.zone.now
        defect.status = 'Reviewed'
        defect.save
        flash[:notice] = 'Defect successfully promoted to pivotal.'
        redirect_to defect_url(defect)
      else
        flash[:error] = 'Defect needs to be assigned to a project before it can be promoted.'
        redirect_to defect_url(defect)
      end
    end
  end
end
