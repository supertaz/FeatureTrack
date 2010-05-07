class Admin::DashboardController < ApplicationController
  before_filter :require_global_admin
  
  def index
  end

end
