require File.dirname(__FILE__) + '/../spec_helper'

describe Environment do
  it "should be valid" do
    Environment.new.should be_valid
  end
end
