class SurveyedController < ApplicationController
  before_action :find_survey

  protected
  def find_survey
    @survey = Survey.find params[:survey_id]
  end

  def require_participant_login!
    # stuff
  end
end