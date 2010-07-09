class DefectsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_see_defects, :except => [:new, :create]
  before_filter :current_user_can_create_defects, :only => [:new, :create]

  def index
    if params.has_key?(:search)
      @search = Story.bugs.search(params[:search])
    else
      @search = Story.bugs.search(:status_in => ['new','unscheduled'], :order => :ascend_by_status)
      @search_title = 'Showing unscheduled stories by default'
    end
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

end
