class ReleasesController < ApplicationController
  def index
    @releases = Release.all
  end
  
  def show
    @release = Release.find(params[:id])
  end
  
  def new
    @release = Release.new
  end
  
  def create
    @release = Release.new(params[:release])
    if @release.save
      flash[:notice] = "Successfully created release."
      redirect_to @release
    else
      render :action => 'new'
    end
  end
  
  def edit
    @release = Release.find(params[:id])
  end
  
  def update
    @release = Release.find(params[:id])
    if @release.update_attributes(params[:release])
      flash[:notice] = "Successfully updated release."
      redirect_to @release
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @release = Release.find(params[:id])
    @release.destroy
    flash[:notice] = "Successfully destroyed release."
    redirect_to releases_url
  end
end
