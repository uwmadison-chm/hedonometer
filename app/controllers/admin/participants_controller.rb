require 'csv'

class Admin::ParticipantsController < AdminController
  def index
    @participant = Participant.new
  end

  def edit
  end

  def update
    return destroy if params[:delete]
    if current_participant.update(update_params)
      flash[:save_message] = "Settings saved!"
    else
      flash[:save_message] = "There was an error!"
    end
    redirect_to edit_admin_survey_participant_path(
      current_survey, current_participant)
  end

  def destroy
    unless params[:confirm_delete]
      flash[:save_message] = "You need to confirm when deleting!"
      return render :edit
    end
    current_participant.delete
    redirect_to admin_survey_participants_path(current_survey)
  end

  def show
    respond_to do |format|
      format.html
      format.csv { render layout: false }
    end
  end

  def create
    @participant = current_survey.participants.create(create_params)
    if not @participant.new_record?
      @participant.send_welcome_message_if_requested!
      flash[:save_message] = "Participant added!"
      redirect_to admin_survey_participants_path(current_survey)
    else
      logger.info "Errors are: #{@participant.errors.inspect}"
      flash.now[:save_message] = "There was an error!"
      current_survey.reload # Force us to remove the ppt from our collection
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
        :send_welcome_message, :external_key, :time_zone)
  end

  def update_params
    params.require(:participant).
    permit(:phone_number, :external_key, :active)
  end
end
