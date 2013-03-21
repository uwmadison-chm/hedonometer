class SurveyPermission < ActiveRecord::Base
  belongs_to :admin
  belongs_to :survey
end
