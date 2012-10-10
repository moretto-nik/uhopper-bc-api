require 'spec_helper'

describe UsersController do
  before :all do
    DatabaseCleaner.clean
  end

  after :all do
    DatabaseCleaner.clean
  end

  context 'tracking' do
    before :each do
      @an_active_api_key = '7f462fb7-ec6e-4e2f-866b-d7e6fb06f90f'
      @user = User.create(:id_cart => 2)
    end

    it "unexhisting user" do
      post 'check_in', {:api_key => @an_active_api_key, :id_cart => @user.id_cart} 

      user = User.find_by_id_cart(2)
      user.id_user += 1
      user.save
      post 'tracking', {:api_key => @an_active_api_key, :id_cart => @user.id_cart, :lat => 123, :lon => 123}
      response.body.should == '{"status":"OK","message":"L\'utente 1 e\' stato tracciato"}'
      user.reload
      user.last_activity.should_not be_nil
    end
  end

  context 'active users' do
    before :each do
      @an_active_api_key = 'f90a7012-0dfd-4fc7-ae43-59bcf5aebc9c'
      @user = User.create(:id_cart => 2, :id_user => 1, :active => true)
    end

    it "response with lat e lon" do
      user = User.find_by_id_cart(2)
      user.active = true
      user.save

      post 'tracking', {:api_key => @an_active_api_key, :id_cart => @user.id_cart, :lat => 123, :lon => 123}
      get 'active', {:api_key => @an_active_api_key}
      response.body.should == '{"status":"OK","message":[{"username":"2.1","lat":123,"lon":123}]}'
    end

    it "response with lat e lon of multiple user" do
      user = User.find_by_id_cart(2)
      post 'check_in', {:api_key => @an_active_api_key, :id_cart => 3} 
      user.active = true
      user.save

      post 'tracking', {:api_key => @an_active_api_key, :id_cart => @user.id_cart, :lat => 123, :lon => 123}
      post 'tracking', {:api_key => @an_active_api_key, :id_cart => 3, :lat => 123, :lon => 123}

      get 'active', {:api_key => @an_active_api_key}
      response.body.should == '{"status":"OK","message":[{"username":"2.1","lat":123,"lon":123}]}'
    end
  end
end
