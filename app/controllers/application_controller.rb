# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user, :current_user_session, :redirect_back_or_default, :store_location, :get_defect_level, :slugify,
                :current_user_can_access_feature_requests, :current_user_can_see_defects, :current_user_can_create_defects,
                :current_user_can_request_features
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
        flash[:error] = "You must be logged in to access this page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:error] = "You must be logged out to access this page"
        redirect_to user_url(current_user)
        return false
      end
    end

    def require_global_admin
      unless current_user && current_user.global_admin
        store_location
        flash[:error] = "You must be an administrator to access that page"
        redirect_to root_url
        return false
      end
    end

    def current_user_can_access_feature_requests(redirect = true)
      unless current_user && (current_user.business_user || current_user.development_manager || current_user.qa_manager || current_user.scrum_master || current_user.global_admin)
        if redirect
          flash[:error] = "You don't have access to that page."
          redirect_to root_url
        end
        return false
      else
        return true
      end
    end

    def current_user_can_request_features(redirect = true)
      unless current_user && (current_user.business_user ||
              current_user.developer ||
              current_user.qa ||
              current_user.development_manager ||
              current_user.qa_manager ||
              current_user.scrum_master ||
              current_user.global_admin)
        if redirect
          flash[:error] = "You don't have access to that page."
          redirect_to root_url
        end
        return false
      else
        return true
      end
    end

    def current_user_can_see_defects(redirect = true)
      unless current_user && (
                      current_user.defect_viewer ||
                      current_user.business_user ||
                      current_user.developer ||
                      current_user.development_manager ||
                      current_user.qa ||
                      current_user.qa_manager ||
                      current_user.scrum_master ||
                      current_user.global_admin)
        if redirect
          flash[:error] = "You don't have access to that page."
          redirect_to root_url
        end
        return false
      else
        return true
      end
    end

    def current_user_can_create_defects(redirect = true)
      unless current_user && (
                      current_user.defect_reporter ||
                      current_user.business_user ||
                      current_user.developer ||
                      current_user.development_manager ||
                      current_user.qa ||
                      current_user.qa_manager ||
                      current_user.scrum_master ||
                      current_user.global_admin)
        if redirect
          flash[:error] = "You don't have access to that page."
          redirect_to root_url
        end
        return false
      else
        return true
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
