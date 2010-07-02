class DefectsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_defects, :except => [:new, :create]
  before_filter :current_user_can_create_defects, :only => [:new, :create]

  def index
    @search = Story.bugs.search(params[:search])
    @defects = @search.all
  end

  def show
    defect = Story.bugs.find(params[:id])
    redirect_to story_url(defect)
#    markdown = RDiscount.new(@defect.description)
#    @defect_description = Sanitize.clean(markdown.to_html, Sanitize::Config::BASIC)
  end

  def new
    @defect = Story.new
    @defect.story_type = 'bug'
  end

  def create
    @defect = Story.new(params[:story])
    @defect.story_type = 'bug'
    @defect.status = 'New'
    @defect.requestor = current_user
    @defect.environment = Environment.find(params[:story].delete('environment_id'))
    if @defect.save
      flash[:notice] = "Successfully created defect."
      redirect_to story_url(@defect)
    else
      render :action => 'new'
    end
  end

  def edit
    @defect = Story.bugs.find(params[:id])
  end

  def update
    @defect = Story.bugs.find(params[:id])
    @defect.environment = Environment.find(params[:story].delete('environment_id'))
    if @defect.description != params[:story]['description']
      description_changed = true
    else
      description_changed = false
    end
    if @defect.update_attributes(params[:story])
      unless @defect.project.nil? || @defect.source_id.nil?
        if description_changed
          project = @defect.project.get_source_project
          story = project.stories.find(@defect.source_id)
          story.update({'description' => @defect.description})
        end
      end
      flash[:notice] = "Successfully updated defect."
      redirect_to story_url(@defect)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @defect = Story.bugs.find(params[:id])
    @defect.destroy
    flash[:notice] = "Successfully destroyed defect."
    redirect_to defects_url
  end

  def promote
    defect = Story.bugs.find(params[:id])
    if (current_user.developer && defect.display_priority.to_i <= 3) || current_user.development_manager || current_user.scrum_master || current_user.global_admin
      unless defect.project.nil?
        project = defect.project.get_source_project
        new_defect = project.stories.create(:name => "P#{defect.display_priority} - " + defect.title,
                                             :labels => "p#{defect.display_priority}",
                                             :requested_by => (defect.requestor.nickname.nil? || defect.requestor.nickname.empty?) ? defect.requestor.firstname : defect.requestor.nickname,
                                             :description => defect.description,
                                             :story_type => defect.story_type.nil? ? 'bug' : defect.story_type,
                                             :other_id => defect.id)
        if new_defect.nil? || new_defect.id.nil?
          flash[:error] = 'Unable to promote defect'
        else
          defect.story_source = defect.project.source
          defect.source_url = new_defect.url
          defect.source_id = new_defect.id
          defect.approver = current_user
          defect.approved_at = Time.zone.now
          defect.reviewer = current_user
          defect.reviewed_at = Time.zone.now
          defect.status = 'Reviewed'
          defect.save
          flash[:notice] = 'Defect successfully promoted to pivotal.'
          redirect_to story_url(defect)
        end
      else
        flash[:error] = 'Defect needs to be assigned to a project before it can be promoted.'
        redirect_to story_url(defect)
      end
    end
  end
end
