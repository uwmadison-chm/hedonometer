# -*- encoding : utf-8 -*-

class ParticipantsController < SurveyedController

  skip_before_action :verify_authenticity_token, only: [:create]


  def create
    @participant = @survey.participants.create participant_params
    if @participant.valid?
      render text: "Created", status: :created
    else
      render text: @participant.errors.to_json, status: :conflict
    end
  end

  def send_login_code
    participant = @survey.participants.where(
      phone_number: PhoneNumber.to_e164(params[:participant][:phone_number])).first
    status = participant ? :ok : :not_found
    if participant
      message = ParticipantTexter.login_code_message(participant)
      message.deliver_and_save!
    end
    render nothing: true, status: status
  end

  protected

  def participant_params
    params.
    require(:participant).
    permit(:phone_number)
  end
end
