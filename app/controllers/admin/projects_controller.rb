class Admin::ProjectsController < ApplicationController
  before_filter :require_global_admin

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    # It would be great to create a pivotal project here, if the source is pivotal...but the API gem would need that
    # functionality to be added, first...
    if @project.save
      flash[:notice] = "Successfully created project."
      redirect_to admin_project_url(@project)
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash[:notice] = "Successfully updated project."
      redirect_to admin_project_url(@project)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to admin_projects_url
  end

  private

  def create_pivotal_project(internal_project)
    PivotalTracker::Project.create(:name => internal_project.name)
  end
end
