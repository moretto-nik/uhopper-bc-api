UhopperRest::Application.routes.draw do
  match 'check_in' => 'users#check_in', :via => :post
  match 'tracking' => 'users#tracking', :via => :post
  match 'check_out/:id_cart' => 'users#check_out', :via => :delete
  match 'active' => 'users#active', :via => :get
  match 'checking_in' => 'users#checking_in', :via => :get
  match 'checking_out' => 'users#checking_out', :via => :get
end
