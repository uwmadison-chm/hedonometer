# -*- encoding : utf-8 -*-

class SessionController < SurveyedController
  skip_before_action :require_participant_login!

  def new
    @participant = Participant.new(login_form_params)
  end

  def destroy
    reset_session
    redirect_to survey_login_path(current_survey)
  end

  def create
    if params[:send_code]
      return send_login_code
    end
    @participant = current_survey.participants.authenticate(
      login_params[:phone_number],
      login_params[:login_code]) || Participant.new(login_params)
    unless @participant.new_record?
      session[:participant_id] = @participant.id
      redirect_to survey_path(current_survey) and return
    end
    # login failed, fall through
    reset_session
    render action: 'new'
  end

  def send_login_code
    number = PhoneNumber.new(params[:participant][:phone_number])
    participant = current_survey.participants.where(phone_number: number.to_e164).first
    if participant
      message = ParticipantTexter.login_code_message(participant)
      message.deliver_and_save!
      redirect_to survey_login_path current_survey, {participant: {phone_number: number.to_s}}
    else
      reset_session
      @participant = Participant.new(login_form_params)
      render action: 'new', status: :not_found
      return false
    end
  end


  protected
  def login_params
    params.require(:participant).
      permit(:phone_number, :login_code)
  end
  def login_form_params
    params.fetch(:participant, {}).permit(:phone_number)
  end
end
