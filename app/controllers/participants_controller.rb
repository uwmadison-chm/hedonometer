# -*- encoding : utf-8 -*-

class ParticipantsController < ApplicationController
  before_action :find_survey

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
      client = Twilio::REST::Client.new @survey.twilio_account_sid, @survey.twilio_auth_token
      client.account.sms.messages.create({
              from: @survey.phone_number.to_e164,
              to: participant.phone_number.to_e164,
              body: "Your login code is #{participant.login_code}"
            })
    end
    render nothing: true, status: status
  end

  protected

  def find_survey
    @survey = Survey.find params[:survey_id]
  end

  def participant_params
    params.
    require(:participant).
    permit(:phone_number)
  end
end
