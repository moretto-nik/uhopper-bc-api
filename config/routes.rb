UhopperRest::Application.routes.draw do
  match 'check_in' => 'users#check_in', :via => :post
  match 'tracking' => 'users#tracking', :via => :post
  match 'check_out/:id_cart' => 'users#check_out', :via => :delete
end
