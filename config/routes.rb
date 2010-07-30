ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'dashboards', :action => 'index'

  map.namespace(:admin) do |admin|
    admin.resources :projects
    admin.resources :users, :member => {:activate => :get}
    admin.resources :environments
  end
  map.admin '/admin', :controller => 'admin/dashboard', :action => 'index'

  map.resource :user, :controller => 'users', :as => 'account'

  map.resources :defects

  map.resources :feature_requests, :member => {:approve => :get, :reject => :get}

  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :user_sessions

  map.current_iteration '/current', :controller => 'iterations', :action => 'current'
  map.assignments '/assignments', :controller => 'iterations', :action => 'assignments'
  map.orphans '/orphans', :controller => 'iterations', :action => 'orphans'
  map.resources :iterations

  map.resources :stories, :except => [:destroy], :member =>
          {       :update_remote_status => :get,
                  :attach_file => [:post, :put],
                  :promote => :get,
                  :start => :get,
                  :qa => :get,
                  :uat => :get,
                  :accept => :get,
                  :reject => :get
          } do |story|
    story.resources :notes, :only => [:create, :edit, :update]
  end
  map.move_story '/stories/:source/:project_id/:story_id/move', :controller => 'stories', :action => 'move'

  map.resources :release_notes

  map.resources :releases

  map.namespace(:api) do |api|
    api.web_hook '/web_hook/:integration_type', :controller => 'web_hook', :action => 'receive_hook',
                 :conditions => {:method => :post}, :integration_type => 'unknown'
  end
end
