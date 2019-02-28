
class Admin::SimulatorController < AdminController
  def index
    if !current_participant
      not_found
    end

    @page_title = "Simulator for participant #{current_participant.external_key}"
    @page_class = "simulator"

    # Downside: TextMessage doesn't know about scheduled_message fields
    # NOTE: scheduled_at vs delivered_at of messages? Do we care?

    to = TextMessage.where(to_number: current_participant.phone_number).map {|m|
      { to: true,
        at: m.delivered_at,
        message: m.message
      }}

    from = TextMessage.where(from_number: current_participant.phone_number).map {|m|
      { to: false,
        at: m.delivered_at,
        message: m.message
      }}

    # TODO: Find real pending messages inside participant.schedule_days
    pending = find_scheduled_messages.map {|m|
      { to: true,
        at: m.scheduled_at,
        message: m.message_or_question_text,
        pending: true
      }}

    @messages = (to + from + pending).sort_by {|m| m[:at]}
  end

  def simulate_send
    # fake-send current scheduled message
    m = find_scheduled_messages.first
    unless m then
      current_survey.schedule_participant! current_participant
      redirect_to action: "index"
    else
      # we kind of fake delivering it in the future
      m.mark_delivered
      m.save!
      OutgoingTextMessage.create!(
        survey: current_survey,
        from_number: current_survey.phone_number,
        to_number: current_participant.phone_number,
        message: m.message_or_question_text,
        scheduled_at: m.scheduled_at,
        delivered_at: m.scheduled_at
      )
      
      # now we reschedule next message for participant
      current_survey.schedule_participant! current_participant
      redirect_to action: "index"
    end
  end

  def simulate_reply
    # TODO: feed this input to state machine
    IncomingTextMessage.create!(
      survey: current_survey,
      from_number: current_participant.phone_number,
      to_number: current_survey.phone_number,
      message: params[:reply],
      delivered_at: Time.now
    )

    redirect_to action: "index"
  end
 
  def current_participant
    @participant ||= Participant.find_by_id(params[:participant_id])
  end
  helper_method :current_participant

  def find_scheduled_messages
    current_participant.schedule_days.collect do |d|
      d.scheduled_messages.scheduled
    end.flatten
  end
end
