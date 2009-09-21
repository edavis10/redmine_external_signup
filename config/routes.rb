ActionController::Routing::Routes.draw do |map|
  map.resource :external_signups, :only => [:create, :update]
end
