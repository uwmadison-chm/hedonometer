# -*- encoding : utf-8 -*-

class SurveyedController < ApplicationController
  before_action :find_survey

  protected
  def current_survey
    @survey ||= Survey.find params[:survey_id]
  end

  def find_survey
    current_survey
  end

  def current_participant
  end

  def require_participant_login!

  end
end
