require File.dirname(__FILE__) + '/../spec_helper'

describe ReleaseNote do
  it "should be valid" do
    ReleaseNote.new.should be_valid
  end
end
