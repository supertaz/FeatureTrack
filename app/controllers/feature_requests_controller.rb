class FeatureRequestsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_access_feature_requests

  def index
    @feature_requests = FeatureRequest.all
  end
  
  def show
    @feature_request = FeatureRequest.find(params[:id])
  end
  
  def new
    @feature_request = FeatureRequest.new
  end
  
  def create
    @feature_request = FeatureRequest.new(params[:feature_request])
    @feature_request.status = 'New'
    @feature_request.requestor = current_user
    if @feature_request.save
      flash[:notice] = "Successfully created feature request."
      redirect_to @feature_request
    else
      render :action => 'new'
    end
  end
  
  def edit
    @feature_request = FeatureRequest.find(params[:id])
  end
  
  def update
    @feature_request = FeatureRequest.find(params[:id])
    if @feature_request.update_attributes(params[:feature_request])
      flash[:notice] = "Successfully updated feature request."
      redirect_to @feature_request
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @feature_request = FeatureRequest.find(params[:id])
    @feature_request.destroy
    flash[:notice] = "Successfully deleted feature request."
    redirect_to feature_requests_url
  end
end
