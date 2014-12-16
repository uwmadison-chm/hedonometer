class Admin::ParticipantsController < AdminController
  def index
    @participant = Participant.new
  end

  def show
  end

  def create
    @participant = current_survey.participants.build(participant_params)
    if @participant.save
      @participant.build_schedule_and_schedule_first_question_if_possible!
      @participant.send_welcome_message_if_requested!
      redirect_to admin_survey_participants_path(current_survey)
    else
      render action: :index
    end
  end

  def current_participant
    @participant ||= current_survey.participants.find(params[:id])
  end
  helper_method :current_participant

  protected
  def participant_params
    params.require(:participant).
      permit(
        :phone_number, :schedule_start_date, :schedule_human_time_after_midnight,
        :send_welcome_message, :external_key)
  end
end
