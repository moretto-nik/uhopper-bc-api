UhopperRest::Application.routes.draw do
  resources :users, except: :edit
  
  match 'check_in' => 'users#check_in', :via => :post, :defaults => {:format => 'json'}
  match 'tracking' => 'users#tracking', :via => :post, :defaults => {:format => 'json'}
  match 'check_out' => 'users#check_out', :via => :delete
end
