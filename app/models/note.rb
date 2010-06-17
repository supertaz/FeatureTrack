class Note < ActiveRecord::Base
  belongs_to :story
  belongs_to :author, :class_name => 'User'
end
