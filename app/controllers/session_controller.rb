# -*- encoding : utf-8 -*-

class SessionController < SurveyedController
  skip_before_action :require_participant_login!

  def new
    @participant = Participant.new
  end

  def destroy
    reset_session
    redirect_to survey_login_path @survey
  end

  def create
    @participant = @survey.participants.authenticate(
      login_params[:phone_number],
      login_params[:login_code]) || Participant.new(login_params)
    render action: 'new'
  end

  protected
  def login_params
    params.require(:participant).
      permit(:phone_number, :login_code)
  end
end
