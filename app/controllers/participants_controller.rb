# -*- encoding : utf-8 -*-

class ParticipantsController < SurveyedController

  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_participant_login!, only: [:create]

  def edit
    @participant = current_participant
  end

  def update
    @participant = current_participant
    logger.debug update_participant_params
    if @participant.update_attributes(update_participant_params)
      redirect_to survey_path(current_survey)
    else
      render :action => :edit
    end
  end

  def create
    # Will primarily be called by other apps via API
    @participant = current_survey.participants.create create_participant_params
    if @participant.valid?
      render text: "Created", status: :created
    else
      render text: @participant.errors.to_json, status: :conflict
    end
  end

  protected

  def create_participant_params
    params.
    require(:participant).
    permit(:phone_number)
  end

  def update_participant_params
    params.
    require(:participant).
    permit(:time_zone)
  end
end
