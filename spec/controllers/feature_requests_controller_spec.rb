require File.dirname(__FILE__) + '/../spec_helper'
 
describe FeatureRequestsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => FeatureRequest.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    FeatureRequest.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    FeatureRequest.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(feature_request_url(assigns[:feature_request]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => FeatureRequest.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    FeatureRequest.any_instance.stubs(:valid?).returns(false)
    put :update, :id => FeatureRequest.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    FeatureRequest.any_instance.stubs(:valid?).returns(true)
    put :update, :id => FeatureRequest.first
    response.should redirect_to(feature_request_url(assigns[:feature_request]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    feature_request = FeatureRequest.first
    delete :destroy, :id => feature_request
    response.should redirect_to(feature_requests_url)
    FeatureRequest.exists?(feature_request.id).should be_false
  end
end
