class Admin < ActiveRecord::Base
  attr_accessible :email, :can_change_admins, :can_create_surveys, :deleted_at
  
  def active?
    deleted_at.nil?
  end
  
  class << self
    
  end
end
