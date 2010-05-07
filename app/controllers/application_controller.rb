# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user, :current_user_session, :redirect_back_or_default, :store_location, :get_defect_level, :slugify
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password

  private

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def store_location
      if request.get?
        session[:return_to] = request.request_uri
      else
        session[:return_to] = request.referrer unless request.xhr?
      end
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to user_url(current_user)
        return false
      end
    end

    def require_global_admin
      unless current_user && current_user.is_global_admin?
        store_location
        flash[:notice] = "You must be an administrator to access that page"
        redirect_to root_url
        return false
      end
    end

    def get_defect_level(defect)
      pri = 10
      defect.labels.split(',').each do |label|
        if label.match(/^p[0-9]$/)
          unless label.gsub(/^p([0-9])$/, '\1').nil?
            pri = label.gsub(/p([0-9])/, '\1').to_i
          end
        end
      end
      pri
    end

    def slugify(string)
      string.downcase.gsub(/^\W*/, '').gsub(/\W*$/, '').gsub(/\W+/, '-')
    end
end
