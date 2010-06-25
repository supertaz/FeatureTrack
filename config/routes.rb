ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'dashboards', :action => 'index'

  map.namespace(:admin) do |admin|
    admin.resources :projects
    admin.resources :users, :member => {:activate => :get}
    admin.resources :environments
  end
  map.admin '/admin', :controller => 'admin/dashboard', :action => 'index'

  map.resource :user, :controller => 'users', :as => 'account'

  map.resources :release_notes

  map.resources :releases

  map.resources :defects, :member => {:promote => :get}

  map.resources :feature_requests, :member => {:approve => :get, :reject => :get}

  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :user_sessions

  map.current_iteration '/current', :controller => 'iterations', :action => 'current'
  map.assignments '/assignments', :controller => 'iterations', :action => 'assignments'
  map.resources :iterations

  map.resources :stories
  map.move_story '/stories/:source/:project_id/:story_id/move', :controller => 'stories', :action => 'move'

  map.namespace(:api) do |api|
    api.web_hook '/web_hook/:integration_type', :controller => 'web_hook', :action => 'receive_hook',
                 :conditions => {:method => :post}, :integration_type => 'unknown'
  end
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
