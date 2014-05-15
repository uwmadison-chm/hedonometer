class Admin::ParticipantsController < AdminController
  def index
  end

  def show
  end

  def current_participant
    @participant ||= current_survey.participants.find(params[:id])
  end
  helper_method :current_participant

  protected
end
