require File.dirname(__FILE__) + '/../spec_helper'
 
describe EnvironmentsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Environment.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Environment.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Environment.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(environment_url(assigns[:environment]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Environment.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Environment.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Environment.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    Environment.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Environment.first
    response.should redirect_to(environment_url(assigns[:environment]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    environment = Environment.first
    delete :destroy, :id => environment
    response.should redirect_to(environments_url)
    Environment.exists?(environment.id).should be_false
  end
end
