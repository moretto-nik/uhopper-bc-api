class User < ActiveRecord::Base
  attr_accessible :id_cart, :id_user

  validates_uniqueness_of :id_cart

  def self.create_not_exists(id_cart)
    if User.exists?(:id_cart => id_cart)
      user = User.find_by_id_cart(id_cart)
    else 
      user = User.new(:id_cart => id_cart)
    end
  end

  def username
    "#{self.id_cart}.#{self.id_user}"
  end

  def check_in
    self.id_user += 1
    bc_result = beancounter 'register'
    if bc_result == true
      self.save
    else
      bc_result
    end
  end

  def tracking
    true
  end
        
  def check_out
    bc_result = beancounter 'deregister'
  end


  private
  @@common_url = 'http://api.beancounter.io/rest/'

  @@action = { 'user_register'     => { :path     => "#{@@common_url}user/register?apikey=api_key",
                                        :method   => :post,
                                        :params   => { :name => "user.name", 
                                                       :surname => "user.surname", 
                                                       :username => "user.username",
                                                       :password => "user.password"
                                                     }
                                      },
               'user_deregister'   => { :path     => "#{@@common_url}user/user.username?apikey=api_key",
                                        :method   => :delete
                                      }
             }


  def generate_url(url)
    url.gsub!("api_key", 'dedcec43-d853-4aa1-b1c6-ba67ee76d708')
    url.gsub!("user.username", self.username)
    url
  end

  def generate_params(params)
    params[:name] = self.username
    params[:surname] = self.username
    params[:username] = self.username
    params[:password] = self.username
    params
  end

  def beancounter(action)
    action_key = "user_#{action}"
    url = generate_url(@@action[action_key][:path])
    params = generate_params(@@action[action_key][:params]) if @@action[action_key][:params]
    RestClient.send(@@action[action_key][:method], url, params) do | req, res, result|
      if result.code == "200" && JSON.parse(req.body)["status"] == "OK"
        true
      else
        JSON.parse(req.body)["message"]
      end
    end
  end
end
