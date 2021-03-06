# -*- encoding : utf-8 -*-

class ParticipantsController < SurveyedController

  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_participant_login!, only: [:create]

  def edit
    @participant = current_participant
    if @participant.schedule_empty?
      # NOTE: This almost definitely is not working right and has likely never been used
      @participant.schedule_start_date = Date.tomorrow
      @participant.schedule_time_after_midnight = 9.hours
      @participant.rebuild_schedule_days!
    end
  end

  def update
    @participant = current_participant
    logger.debug { "  update_participant_params: #{update_participant_params}" }
    if @participant.update_attributes(update_participant_params)
      q = current_survey.schedule_participant! @participant
      logger.debug("Scheduled #{q.inspect}")
      if q
        ParticipantTexter.delay(run_at: q.scheduled_at).deliver_scheduled_message!(q.id)
      end
      flash[:save_message] = "Saved!"
      redirect_to survey_path(current_survey)
    else
      render :action => :edit
    end
  end

  def new
  end

  def create
    # Will primarily be called by other apps via API
    @participant = current_survey.participants.build create_participant_params
    if @participant.save
      # Timezone is copied from survey
      Time.use_zone @participant.time_zone do
        @participant.send_welcome_message_if_requested!
        render plain: "Created", status: :created
      end
    else
      render plain: @participant.errors.to_json, status: :conflict
    end
  end

  protected

  def create_participant_params
    params.
    require(:participant).
    permit(:phone_number, :schedule_start_date, :schedule_time_after_midnight, :send_welcome_message)
  end

  def update_participant_params
    params.
    require(:participant).
    permit(:time_zone, :schedule_days_attributes => [:id, :participant_local_date, :time_ranges_string, :skip])
  end
end
