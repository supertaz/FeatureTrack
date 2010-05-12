require File.dirname(__FILE__) + '/../spec_helper'

describe FeatureRequest do
  it "should be valid" do
    FeatureRequest.new.should be_valid
  end
end
