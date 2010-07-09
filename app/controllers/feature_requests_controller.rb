class FeatureRequestsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_modify_feature_requests, :except => [:new, :create, :index, :show]
  before_filter :current_user_can_request_features, :only => [:new, :create]

  def index
    @search = Story.features.search(params[:search])
    @feature_requests = @search.all
  end

  def show
    feature_request = Story.features.find(params[:id])
    redirect_to story_url(feature_request)
  end

  def new
    @feature_request = Story.new
    @feature_request.story_type = 'feature'
  end

  def create
    @feature_request = Story.new(params[:story])
    @feature_request.story_type = 'feature'
    @feature_request.status = 'New'
    @feature_request.requestor = current_user
    if @feature_request.save
      flash[:notice] = "Successfully created feature request."
      redirect_to story_url(@feature_request)
    else
      render :action => 'new'
    end
  end

  def edit
    @feature_request = Story.features.find(params[:id])
  end

  def update
    @feature_request = Story.features.find(params[:id])
    if @feature_request.update_attributes(params[:story])
      flash[:notice] = "Successfully updated feature request."
      redirect_to story_url(@feature_request)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @feature_request = Story.features.find(params[:id])
    @feature_request.destroy
    flash[:notice] = "Successfully deleted feature request."
    redirect_to feature_requests_url
  end

  def reject
    if current_user.scrum_master || current_user.global_admin
      feature = Story.features.find(params[:id])
      feature.approver = current_user
      feature.rejected_at = Time.zone.now
      feature.status = 'Rejected'
      feature.save
      flash[:notice] = 'Feature rejected.'
      redirect_to story_url(feature)
    else
      flash[:error] = 'You don\'t have access to that functionality.'
      redirect_to feature_requests_url
    end
  end
end
