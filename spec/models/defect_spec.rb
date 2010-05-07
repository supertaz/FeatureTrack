require File.dirname(__FILE__) + '/../spec_helper'

describe Defect do
  it "should be valid" do
    Defect.new.should be_valid
  end
end
