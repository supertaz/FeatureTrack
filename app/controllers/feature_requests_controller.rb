class FeatureRequestsController < ApplicationController
  before_filter :require_user
  before_filter :current_user_can_modify_feature_requests, :except => [:new, :create, :index, :show]
  before_filter :current_user_can_request_features, :only => [:new, :create]

  def index
    @search = FeatureRequest.search(params[:search])
    @feature_requests = @search.all
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

  def approve
    if current_user.scrum_master || current_user.global_admin
      feature = FeatureRequest.find(params[:id])
      unless feature.project.nil?
        key_object = current_user.get_api_key('pivotal')
        PivotalTracker::Client.token = key_object.api_key unless key_object.nil?
        project = feature.project.get_source_project
        new_feature = project.stories.create(:name => feature.title,
                                             :description => feature.description,
                                             :requested_by => (feature.reporter.nickname.nil? || feature.reporter.nickname.empty?) ? feature.reporter.firstname : feature.reporter.nickname,
                                             :story_type => feature.story_type.nil? ? 'feature' : feature.story_type)
        feature.story_source = feature.project.source
        feature.story_id = new_feature.id
        feature.approver = current_user
        feature.approved_at = Time.zone.now
        feature.status = 'Approved'
        feature.save
        flash[:notice] = 'Feature successfully promoted to story.'
        redirect_to feature_request_url(feature)
      else
        flash[:error] = 'Feature request needs to be assigned to a project before it can be approved.'
        redirect_to feature_request_url(feature)
      end
    else
      flash[:error] = 'You don\'t have access to that functionality.'
      redirect_to feature_requests_url
    end
  end

  def reject
    if current_user.scrum_master || current_user.global_admin
      feature = FeatureRequest.find(params[:id])
      feature.approver = current_user
      feature.rejected_at = Time.zone.now
      feature.status = 'Rejected'
      feature.save
      flash[:notice] = 'Feature rejected.'
      redirect_to feature_request_url(feature)
    else
      flash[:error] = 'You don\'t have access to that functionality.'
      redirect_to feature_requests_url
    end
  end
end
