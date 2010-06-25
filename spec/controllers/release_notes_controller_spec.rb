require File.dirname(__FILE__) + '/../spec_helper'
 
describe ReleaseNotesController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => ReleaseNote.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    ReleaseNote.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    ReleaseNote.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(release_note_url(assigns[:release_note]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => ReleaseNote.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    ReleaseNote.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ReleaseNote.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    ReleaseNote.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ReleaseNote.first
    response.should redirect_to(release_note_url(assigns[:release_note]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    release_note = ReleaseNote.first
    delete :destroy, :id => release_note
    response.should redirect_to(release_notes_url)
    ReleaseNote.exists?(release_note.id).should be_false
  end
end
