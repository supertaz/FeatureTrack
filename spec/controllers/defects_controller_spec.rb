require File.dirname(__FILE__) + '/../spec_helper'
 
describe DefectsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Defect.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Defect.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Defect.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(defect_url(assigns[:defect]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Defect.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Defect.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Defect.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    Defect.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Defect.first
    response.should redirect_to(defect_url(assigns[:defect]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    defect = Defect.first
    delete :destroy, :id => defect
    response.should redirect_to(defects_url)
    Defect.exists?(defect.id).should be_false
  end
end
