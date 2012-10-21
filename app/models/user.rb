class User < ActiveRecord::Base
  attr_accessible :id_cart, :id_user, :active, :last_activity

  validates_uniqueness_of :id_cart

  def self.create_not_exists(id_cart)
    if User.exists?(:id_cart => id_cart)
      user = User.find_by_id_cart(id_cart)
    else 
      user = User.new(:id_cart => id_cart)
    end
  end

  def self.active_users(api_key)
    active_users = User.find_all_by_active_and_api_key(true, api_key).select { |user| user.last_activity }
    return true, "Not exists active users" if active_users.empty?

    json = []
    active_users.each do |user|
      lat, lon = user.beancounter_last_activity(api_key)
      json << {:username => user.username, :lat => lat, :lon => lon} if lat
    end

    return true, json
  end

  def self.checking_in(api_key)
    User.find_all_by_active_and_api_key(true, api_key).count
  end

  def self.checking_out(api_key)
    User.find_all_by_active_and_api_key(false, api_key).count
  end

  def username
    "#{self.id_cart}.#{self.id_user}"
  end

  def check_in(api_key)
    self.id_user += 1
    bc_result = beancounter 'register', api_key
    if bc_result == true
      self.active = true
      self.api_key = api_key
      self.save
    else
      self.delete
      bc_result
    end
  end

  def tracking(api_key, lat, lon)
    token = beancounter 'authenticate', api_key
    if token
      beancounter_tracking(token, lat, lon)
    else
      token
    end
  end

  def check_out(api_key)
    bc_result = beancounter 'deregister', api_key
    if bc_result == true
      self.active = false 
      self.save
    end
    bc_result
  end


  private
  @@common_url = 'http://194.116.82.81:8080/beancounter-platform/rest/'

  @@action = { 'register'     => { :path     => "#{@@common_url}user/register?apikey=api_key",
                                   :method   => :post,
                                   :params   => { :name => "user.name", 
                                                  :surname => "user.surname", 
                                                  :username => "user.username",
                                                  :password => "user.password"
                                                }
                                 },
               'deregister'   => { :path     => "#{@@common_url}user/user.username?apikey=api_key",
                                   :method   => :delete
                                 },
               'authenticate' => { :path     => "#{@@common_url}user/user.username/authenticate?apikey=api_key",
                                   :method   => :post,
                                   :params   => { :username => "user.username",
                                                  :password => "user.password"
                                   }
                                 }
             }


  def generate_url(url, api_key = nil)
    #url.gsub!("api_key", '7f462fb7-ec6e-4e2f-866b-d7e6fb06f90f')
    url.gsub!("api_key", api_key) if api_key.present?
    url.gsub!("user.username", self.username)
    url
  end

  def generate_params(params)
    params[:name] = self.username
    params[:surname] = self.username
    params[:username] = self.username
    params[:password] = "pwd#{self.username}"
    params
  end

  def beancounter(action, api_key = nil)
    url = generate_url(@@action[action][:path], api_key)
    params = generate_params(@@action[action][:params]) if @@action[action][:params]
    RestClient.send(@@action[action][:method], url, params) do | req, res, result|
      if result.code == "200" && JSON.parse(req.body)["status"] == "OK"
        return JSON.parse(req.body)["object"]["userToken"] if action == "authenticate"
        true
      else
        JSON.parse(req.body)["message"]
      end
    end
  end

  def beancounter_tracking(token, lat, lon)
    params = "activity={\"object\":{\"type\":\"MALL-PLACE\",\"url\":null,\"name\":\"test-uh\",\"description\":\"test-uh\",\"lat\":#{lat},\"lon\":#{lon},\"mall\":\"123\",\"sensor\":\"456\"},\"context\":{\"date\":null,\"service\":null,\"mood\":null},\"verb\":\"LOCATED\"}"
    url = "http://194.116.82.81:8080/beancounter-platform/rest/activities/add/#{self.username}?token=#{token}"
    RestClient.post(url, params) do | req, res, result|
      if result.code == "200" && JSON.parse(req.body)["status"] == "OK"
        self.update_attributes(:last_activity => JSON.parse(req.body)["object"])
        true
      else
        JSON.parse(req.body)["message"]
      end
    end
  end

  public
  def beancounter_last_activity(api_key)
    url = "http://194.116.82.81:8080/beancounter-platform/rest/activities/#{self.last_activity}?apikey=#{api_key}"
    RestClient.get url do | req, res, result|
      if result.code == "200" && JSON.parse(req.body)["status"] == "OK"
        return JSON.parse(req.body)["object"]["activity"]["object"]["lat"], JSON.parse(req.body)["object"]["activity"]["object"]["lon"]
      else
        return false, JSON.parse(req.body)["message"]
      end
    end
  end
end
