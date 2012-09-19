require 'spec_helper'

describe UsersController do
  before :all do
    DatabaseCleaner.clean
  end

  after :all do
    DatabaseCleaner.clean
  end

  context 'check in' do
    it 'of not saved cart' do
      post 'check_in', {:id_cart => 1}
      response.body.should == '{"status":"OK","message":"L\'utente 1 ha effettuato il check in"}'
    end

    it 'of saved cart' do
      User.new(:id_cart => 2, :id_user => 15).save
      
      post 'check_in', {:id_cart => 2} 
      response.body.should == '{"status":"OK","message":"L\'utente 16 ha effettuato il check in"}'
    end
  end

  context 'tracking' do
    it 'not exists user' do
      any_not_exists_id_cart = 100
      
      post 'tracking', {:id_cart => any_not_exists_id_cart}
      response.body.should == '{"status":"NOK","message":"Id Cart not exists"}'
    end

    it 'exists user' do
      User.new(:id_cart => 3, :id_user => 15).save
      any_exists_id_cart = 3
      
      post 'tracking', {:id_cart => any_exists_id_cart}
      response.body.should == '{"status":"OK","message":"L\'utente 15 e\' stato tracciato"}'
    end
  end

  context 'check_out' do
    it 'not exists user' do
      any_not_exists_id_cart = 100
      
      delete 'check_out', {:id_cart => any_not_exists_id_cart}
      response.body.should == '{"status":"NOK","message":"Id Cart not exists"}'
    end

    it 'exists user' do
      User.new(:id_cart => 3, :id_user => 15).save
      any_exists_id_cart = 3
      
      delete 'check_out', {:id_cart => any_exists_id_cart}
      response.body.should == '{"status":"OK","message":"L\'utente 15 ha effettuato il check out"}'
    end
  end
end
