require 'csv'

class Admin::ParticipantsController < AdminController
  def index
    @participant = Participant.new
  end

  def edit
  end

  def update
    if current_participant.update(update_params)
      flash[:save_message] = "Settings saved!"
    else
      flash[:save_message] = "There was an error!"
    end
    redirect_to edit_admin_survey_participant_path(
      current_survey, current_participant)

  end

  def show
    respond_to do |format|
      format.html
      format.csv { render layout: false }
    end
  end

  def create
    @participant = current_survey.participants.build(create_params)
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
  def create_params
    params.require(:participant).
      permit(
        :phone_number, :schedule_start_date, :schedule_human_time_after_midnight,
        :send_welcome_message, :external_key)
  end

  def update_params
    params.require(:participant).
    permit(:phone_number, :external_key, :active)
  end
end
