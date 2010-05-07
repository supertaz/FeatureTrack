class User < ActiveRecord::Base
  attr_accessible :email, :crypted_password, :password_salt, :persistence_token, :single_access_token, :perishable_token,
                  :login_count, :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip,
                  :password, :password_confirmation, :firstname, :lastname, :work, :home, :mobile, :nickname, :active

  acts_as_authentic
  acts_as_authorized_user
  acts_as_authorizable

  has_many :source_api_keys

  def get_api_key(source)
    unless self.source_api_keys.nil?
      self.source_api_keys.find_by_source(source)
    else
      nil
    end
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end
