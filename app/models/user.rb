class User < ActiveRecord::Base
  attr_accessible :email, :crypted_password, :password_salt, :persistence_token, :single_access_token, :perishable_token,
                  :login_count, :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip,
                  :password, :password_confirmation, :firstname, :lastname, :work, :home, :mobile, :nickname, :active,
                  :defect_viewer, :defect_reporter, :business_user, :technology_team, :developer, :qa, :scrum_master, :global_admin

  acts_as_authentic
  acts_as_authorized_user
  acts_as_authorizable

  has_many :source_api_keys

  def defect_reporter
    self.is_defect_reporter?
  end

  def defect_reporter=(dr)
    if dr.to_i == 1
      self.is_defect_reporter
    else
      self.is_not_defect_reporter
    end
  end

  def defect_viewer
    self.is_defect_viewer?
  end

  def defect_viewer=(dv)
    if dv.to_i == 1
      self.is_defect_viewer
    else
      self.is_not_defect_viewer
    end
  end

  def business_user
    self.is_business_user?
  end

  def business_user=(bu)
    if bu.to_i == 1
      self.is_business_user
    else
      self.is_not_business_user
    end
  end

  def technology_team
    self.is_technology_team?
  end

  def technology_team=(tt)
    if tt.to_i == 1
      self.is_technology_team
    else
      self.is_not_technology_team
    end
  end

  def developer
    self.is_developer?
  end

  def developer=(d)
    if d.to_i == 1
      self.is_developer
    else
      self.is_not_developer
    end
  end

  def qa
    self.is_qa?
  end

  def qa=(qa_val)
    if qa_val.to_i == 1
      self.is_qa
    else
      self.is_not_qa
    end
  end

  def scrum_master
    self.is_scrum_master?
  end

  def scrum_master=(sm)
    if sm.to_i == 1
      self.is_scrum_master
    else
      self.is_not_scrum_master
    end
  end

  def global_admin
    self.is_global_admin?
  end

  def global_admin=(ga)
    if ga.to_i == 1
      self.is_global_admin
    else
      self.is_not_global_admin
    end
  end

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
