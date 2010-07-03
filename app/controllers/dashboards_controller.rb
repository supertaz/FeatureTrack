class DashboardsController < ApplicationController
  before_filter :require_user

  def index
    @default_refresh = 90
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @statuses = Hash.new
    Project.active.each do |project|
      project.stories.each do |story|
        add_to_lane_hash(@statuses, story.status.capitalize, story)
      end
    end
  end
end
