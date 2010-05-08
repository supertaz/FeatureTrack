class DefectsController < ApplicationController
  before_filter :require_user
  
  def index
    @defects = Defect.all
  end

  def show
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
end
