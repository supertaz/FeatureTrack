require 'spec_helper'

describe SourceAPIKey do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :source => "value for source",
      :api_key => "value for api_key"
    }
  end

  it "should create a new instance given valid attributes" do
    SourceAPIKey.create!(@valid_attributes)
  end
end
