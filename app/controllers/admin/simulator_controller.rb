
class Admin::SimulatorController < AdminController
  def index
    if !current_participant
      not_found
    end

    @page_title = "Simulator for participant #{current_participant.external_key}"

    @messages = []
    # TODO: Recover messages from text_messages, or use something else?
    # Downside: doesn't know about scheduled_message fields
    # scheduled_at vs delivered_at

  end
 
  def current_participant
    @participant ||= Participant.find_by_id(params[:participant_id])
  end
  helper_method :current_participant
end
