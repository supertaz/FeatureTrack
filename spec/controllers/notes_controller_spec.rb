require 'spec_helper'

describe NotesController do

  #Delete these examples and add some real ones
  it "should use NotesController" do
    controller.should be_an_instance_of(NotesController)
  end


  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
      response.should be_success
    end
  end
end
