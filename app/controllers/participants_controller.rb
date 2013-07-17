class ParticipantsController < ApplicationController
  before_action :find_survey

  def create
    @participant = @survey.participants.create participant_params
    if @participant.valid?
      render nothing: true, status: :created
    else
      render text: @participant.errors.to_json, status: :conflict
    end
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
