class DashboardsController < ApplicationController
  before_filter :require_user

  def index
    @default_refresh = 90
    @refresh = params[:refresh].nil? ? @default_refresh : params[:refresh].to_i
    @statuses = Hash.new
    Project.active.each do |project|
      begin
        iteration = PivotalTracker::Iteration.current(project.get_source_project)
        iteration.stories.each do |story|
          add_to_lane_hash(@statuses, story.current_state, story)
        end
      rescue => e
        if !(defined? e.response) || e.response.nil?
          flash.now[:error] = "#{e.class} exception, trying again in 15 seconds.<br>(#{e.message})"
          @backtrace = e.backtrace
          @refresh = 15
        else
          flash.now[:error] = "Remote source returned an exception: #{e.response}&nbsp;&nbsp;Will try again in 15 seconds.<br>(#{e.message})"
          @backtrace = e.backtrace
          @refresh = 15
        end
      end
    end
  end
end
