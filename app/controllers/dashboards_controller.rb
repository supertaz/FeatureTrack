class DashboardsController < ApplicationController
  def index
    projects = Dashboard.all
  end
end
