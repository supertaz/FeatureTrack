ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'iterations', :action => 'current'

  map.namespace(:admin) do |admin|
    admin.resources :projects
    admin.resources :users, :member => {:activate => :get}
    admin.resources :environments
  end
  map.admin '/admin', :controller => 'admin/dashboard', :action => 'index'

  map.resource :user, :controller => 'users', :as => 'account'

  map.resource :dashboard

  map.resources :defects

  map.resources :feature_requests, :member => {:approve => :get, :reject => :get}

  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :user_sessions

  map.current_iteration '/current', :controller => 'iterations', :action => 'current'
  map.assignments '/assignments', :controller => 'iterations', :action => 'assignments'
  map.resources :iterations

  map.resources :stories

#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
