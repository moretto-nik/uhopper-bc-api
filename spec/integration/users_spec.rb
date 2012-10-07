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
      post 'tracking', {:id_cart => @user.id_cart, :lat => 123, :lon => 123}
      response.body.should == '{"status":"OK","message":"L\'utente 15 e\' stato tracciato"}'
    end
  end
end
