require 'spec_helper'

describe AttachedFile do
  before(:each) do
    @valid_attributes = {
      :story_id => 1,
      :attached_by_id => 1,
      :attached_file_name => "value for attached_file_name",
      :attached_content_type => "value for attached_content_type",
      :attached_file_size => 1,
      :attached_updated_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    AttachedFile.create!(@valid_attributes)
  end
end
