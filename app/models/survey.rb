class Survey < ActiveRecord::Base
  has_many :survey_permissions
  has_many :admins, :through => :survey_permissions
end
