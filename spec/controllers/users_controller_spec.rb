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
      u = User.new(:id_cart => 1)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return(true)
      
      post 'check_in', {:api_key => 'any_api_key', :id_cart => 1}
      u.active.should be_true
      response.body.should == '{"status":"OK","message":"L\'utente 1 ha effettuato il check in"}'
    end

    it 'of saved cart and brancounter success' do
      u = create_user(5, 15)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return(true)

      post 'check_in', {:api_key => 'any_api_key', :id_cart => u.id_cart} 
      u.active.should be_true
      response.body.should == '{"status":"OK","message":"L\'utente 16 ha effettuato il check in"}'
    end

    it 'of saved cart and beancounter failed' do
      u = create_user(5, 1)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return("fail registration")

      post 'check_in', {:api_key => 'any_api_key', :id_cart => u.id_cart} 
      response.body.should == '{"status":"NOK","message":"Beancounter : fail registration"}'
    end
  end

  context 'tracking' do
    it 'not exists user' do
      any_not_exists_id_cart = 100

      post 'tracking', {:id_cart => any_not_exists_id_cart}
      response.body.should == '{"status":"NOK","message":"Id Cart not exists"}'
    end

    it 'exists user' do
      u = create_user(3, 15)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return(true)

      post 'tracking', {:id_cart => u.id_cart, :lat => 123, :lon => 123}
      response.body.should == '{"status":"OK","message":"L\'utente 15 e\' stato tracciato"}'
    end
  end

  context 'check_out' do
    it 'not exists user' do
      any_not_exists_id_cart = 100

      delete 'check_out', {:api_key => 'any_api_key', :id_cart => any_not_exists_id_cart}
      response.body.should == '{"status":"NOK","message":"Id Cart not exists"}'
    end

    it 'exists user and beancounter success' do
      u = create_user(4,15) 
      User.stub(:find_by_id_cart).and_return(u)
      u.stub(:check_out).and_return(true)

      delete 'check_out', {:api_key => 'any_api_key', :id_cart => u.id_cart}
      u.active.should be_false
      response.body.should == '{"status":"OK","message":"L\'utente 15 ha effettuato il check out"}'
    end
    
    it 'exists user and beancounter fail' do
      u = create_user(6,15) 
      u.active = true
      User.stub(:find_by_id_cart).and_return(u)
      u.stub(:beancounter).and_return("fail deregistration")

      delete 'check_out', {:api_key => 'any_api_key', :id_cart => u.id_cart}
      u.active.should be_true
      response.body.should == '{"status":"NOK","message":"Beancounter : fail deregistration"}'
    end
  end

  private
  def create_user(id_cart, id_user=nil)
    u = User.new(:id_cart => id_cart, :id_user => id_user)
    u.save
    u
  end
end
