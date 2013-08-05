# -*- encoding : utf-8 -*-

class SurveyedController < ApplicationController
  protected
  def current_survey
    @current_survey ||= Survey.find params[:survey_id]
  end
  helper_method :current_survey

  def current_participant
  end
  helper_method :current_participant

  def require_participant_login!

  end
end
