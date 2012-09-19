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
      
      post 'check_in', {:id_cart => 1}
      response.body.should == '{"status":"OK","message":"L\'utente 1 ha effettuato il check in"}'
    end

    it 'of saved cart and brancounter success' do
      u = create_user(5, 15)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return(true)

      post 'check_in', {:id_cart => u.id_cart} 
      response.body.should == '{"status":"OK","message":"L\'utente 16 ha effettuato il check in"}'
    end

    it 'of saved cart and beancounter failed' do
      u = create_user(5)
      User.stub(:create_not_exists).and_return(u)
      u.stub(:beancounter).and_return("fail registration")

      post 'check_in', {:id_cart => u.id_cart} 
      response.body.should == '{"status":"NOK","message":"Beancounter : fail registration"}'
    end
  end

  context 'tracking' do
    it 'not exists user' do
      any_not_exists_id_cart = 100

      post 'tracking', {:id_cart => any_not_exists_id_cart}
      response.body.should == '{"status":"NOK","message":"Beancounter : false"}'
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
      response.body.should == '{"status":"NOK","message":"Beancounter : false"}'
    end

    it 'exists user' do
      User.new(:id_cart => 4, :id_user => 15).save
      any_exists_id_cart = 4

      delete 'check_out', {:id_cart => any_exists_id_cart}
      response.body.should == '{"status":"OK","message":"L\'utente 15 ha effettuato il check out"}'
    end
  end

  private
  def create_user(id_cart, id_user=nil)
    u = User.new(:id_cart => id_cart, :id_user => id_user)
    u.save
    u
  end
end
