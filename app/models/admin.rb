class Admin < ActiveRecord::Base
  attr_accessible :email, :can_change_admins, :can_create_surveys, :deleted_at
  
  def active?
    deleted_at.nil?
  end
  
  def password_match?(pw)
    self if (
      password_hash.present? and 
      password_hash == BCrypt::Engine.hash_secret(pw, password_salt)) 
  end
  
  class << self
    def authenticate(email, password)
      a = where(email:email).first
      a and a.password_match? password
    end
  end
  
end
