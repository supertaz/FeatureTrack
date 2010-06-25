require File.dirname(__FILE__) + '/../spec_helper'
 
describe ReleasesController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Release.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Release.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Release.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(release_url(assigns[:release]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Release.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Release.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Release.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    Release.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Release.first
    response.should redirect_to(release_url(assigns[:release]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    release = Release.first
    delete :destroy, :id => release
    response.should redirect_to(releases_url)
    Release.exists?(release.id).should be_false
  end
end
