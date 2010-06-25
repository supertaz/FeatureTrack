require File.dirname(__FILE__) + '/../spec_helper'

describe Release do
  it "should be valid" do
    Release.new.should be_valid
  end
end
