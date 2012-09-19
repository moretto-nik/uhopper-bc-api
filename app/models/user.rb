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

  def check_in
    self.id_user += 1 
    self.save
    true 
  end

  def tracking
    true
  end
        
  def check_out
    true
  end

  def delete
    true
  end

end
