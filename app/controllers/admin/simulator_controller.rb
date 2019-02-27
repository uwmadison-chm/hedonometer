
class Admin::SimulatorController < AdminController
  def index
    if !current_participant
      not_found
    end

    @page_title = "Simulator for participant #{current_participant.external_key}"

    # Downside: TextMessage doesn't know about scheduled_message fields
    # TODO: scheduled_at vs delivered_at of messages? Do we care?

    to = TextMessage.where(to_number: current_participant.phone_number).map {|m|
      { class: "to",
        at: m.delivered_at,
        message: m.message
      }}

    from = TextMessage.where(from_number: current_participant.phone_number).map {|m|
      { class: "from",
        at: m.delivered_at,
        message: m.message
      }}

    pending = [
      { class: "to",
        at: Time.now + 1.hours,
        message: "Test of pending messages",
        pending: true
      }
    ]

    @messages = to + from + pending
  end

  def simulate_send
    # TODO
    TextMessage.create!(
      to_number: current_participant.phone_number,
      from_number: current_survey.phone_number,
    )
    redirect_to action: "index"
  end

  def simulate_reply
    # TODO
    redirect_to action: "index"
  end
 
  def current_participant
    @participant ||= Participant.find_by_id(params[:participant_id])
  end
  helper_method :current_participant
end
