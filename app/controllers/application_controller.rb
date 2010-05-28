# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user, :current_user_session, :redirect_back_or_default, :store_location, :get_defect_level, :slugify,
                :current_user_can_access_feature_requests, :current_user_can_see_defects, :current_user_can_create_defects,
                :current_user_can_request_features, :current_user_can_see_stories
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

    def current_user_can_see_stories(redirect = true)
      unless current_user && (
                      current_user.story_viewer ||
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

    def add_to_lane_hash(lanes, label, story, accepted_bubble_up = true)
      unless lanes.has_key?(label)
        lanes[label] = Hash.new
        lanes[label]['name'] = label.capitalize
        lanes[label]['total_items'] = 0
        lanes[label]['total_features'] = 0
        lanes[label]['total_defects'] = 0
        lanes[label]['total_chores'] = 0
        lanes[label]['total_others'] = 0
        lanes[label]['open_items'] = 0
        lanes[label]['open_features'] = 0
        lanes[label]['open_defects'] = 0
        lanes[label]['open_chores'] = 0
        lanes[label]['open_others'] = 0
        accepted_other = Array.new
        accepted_features = Array.new
        accepted_priority = Array.new
        accepted_defects = Array.new
        accepted_chores = Array.new
        todo_other = Array.new
        todo_features = Array.new
        todo_priority = Array.new
        todo_defects = Array.new
        todo_chores = Array.new
        lanes[label]['accepted'] = {'other' => accepted_other,
                                    'features' => accepted_features,
                                    'priority' => accepted_priority,
                                    'defects' => accepted_defects,
                                    'chores' => accepted_chores
        }
        lanes[label]['todo'] = {    'other' => todo_other,
                                    'features' => todo_features,
                                    'priority' => todo_priority,
                                    'defects' => todo_defects,
                                    'chores' => todo_chores
        }
      end

      if accepted_bubble_up && story.current_state == 'accepted'
        target = lanes[label]['accepted']
      else
        target = lanes[label]['todo']
      end
      lanes[label]['total_items'] += 1
      lanes[label]['open_items'] += 1 unless story.current_state == 'accepted'
      case story.story_type
        when 'feature'
          target['features'] << story
          lanes[label]['total_features'] += 1
          lanes[label]['open_features'] += 1 unless story.current_state == 'accepted'
        when 'bug'
          if get_defect_level(story) > 2
            target['defects'] << story
          else
            target['priority'] << story
          end
          lanes[label]['total_defects'] += 1
          lanes[label]['open_defects'] += 1 unless story.current_state == 'accepted'
        when 'chore'
          target['chores'] << story
          lanes[label]['total_chores'] += 1
          lanes[label]['open_chores'] += 1 unless story.current_state == 'accepted'
        else
          target['other'] << story
          lanes[label]['total_others'] += 1
          lanes[label]['open_others'] += 1 unless story.current_state == 'accepted'
      end
    end
end
