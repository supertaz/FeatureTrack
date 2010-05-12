class DefectsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_defects, :except => [:new, :create]
  before_filter :current_user_can_create_defects, :only => [:new, :create]

  def index
    @defects = Defect.all.sort {|a,b| a.calculate_execution_priority <=> b.calculate_execution_priority}
  end

  def show
    key_object = current_user.get_api_key('pivotal')
    PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
    @defect = Defect.find(params[:id])
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
    if @defect.update_attributes(params[:defect])
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
    if current_user.scrum_master || current_user.global_admin
      defect = Defect.find(params[:id])
      unless defect.project.nil?
        key_object = current_user.get_api_key('pivotal')
        PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
        project = defect.project.get_source_project
        new_defect = project.stories.create(:name => "P#{defect.display_priority} - " + defect.title,
                                             :labels => "p#{defect.display_priority}",
                                             :description => defect.description,
                                             :story_type => defect.story_type.nil? ? 'bug' : defect.story_type)
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
