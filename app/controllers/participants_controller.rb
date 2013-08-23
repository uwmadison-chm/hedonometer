# -*- encoding : utf-8 -*-

class ParticipantsController < SurveyedController

  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_participant_login!, only: [:create]

  def edit
    @participant = current_participant
    @participant.build_schedule_days if @participant.schedule_empty?
  end

  def update
    @participant = current_participant
    logger.debug "  update_participant_params: #{update_participant_params}"
    if @participant.update_attributes(update_participant_params)
      q = @participant.schedule_survey_question_and_save!
      logger.debug("Scheduled #{q.inspect}")
      if q
        ParticipantTexter.delay(run_at: q.scheduled_at).deliver_scheduled_question!(q.id)
      end
      redirect_to survey_path(current_survey)
    else
      render :action => :edit
    end
  end

  def create
    # Will primarily be called by other apps via API
    @participant = current_survey.participants.build create_participant_params
    # All solutions are hacks; move to survey
    @participant.time_zone = "Central Time (US & Canada)"
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
    permit(:time_zone, :schedule_days_attributes => [:id, :date, :time_ranges_string, :skip])
  end
end
