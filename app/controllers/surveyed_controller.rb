# -*- encoding : utf-8 -*-

class SurveyedController < ApplicationController
  layout 'participant'

  before_action :require_participant_login!

  protected
  def current_survey
    @current_survey ||= Survey.find params[:survey_id]
  end
  helper_method :current_survey

  def current_participant
    @current_participant ||= current_survey.participants.where(id: session[:participant_id]).first
  end
  helper_method :current_participant

  def require_participant_login!
    if current_participant
      Time.zone = current_participant.time_zone
    else
      redirect_to survey_login_path(current_survey) and return false
    end
  end
end
