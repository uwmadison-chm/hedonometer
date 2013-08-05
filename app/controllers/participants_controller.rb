# -*- encoding : utf-8 -*-

class ParticipantsController < SurveyedController

  skip_before_action :verify_authenticity_token, only: [:create]

  def edit
  end

  def update
  end

  def create
    # Will primarily be called by other apps via API
    @participant = current_survey.participants.create participant_params
    if @participant.valid?
      render text: "Created", status: :created
    else
      render text: @participant.errors.to_json, status: :conflict
    end
  end

  protected

  def participant_params
    params.
    require(:participant).
    permit(:phone_number)
  end

end
