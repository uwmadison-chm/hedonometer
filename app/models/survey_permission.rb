# -*- encoding : utf-8 -*-
class SurveyPermission < ApplicationRecord
  belongs_to :admin
  belongs_to :survey
end
