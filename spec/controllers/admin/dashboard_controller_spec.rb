require 'spec_helper'

describe Admin::DashboardController do

  #Delete these examples and add some real ones
  it "should use Admin::DashboardController" do
    controller.should be_an_instance_of(Admin::DashboardController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
end
