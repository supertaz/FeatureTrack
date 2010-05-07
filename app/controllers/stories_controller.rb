class StoriesController < ApplicationController
  def index
    @stories = Project.stories.all
  end
end
