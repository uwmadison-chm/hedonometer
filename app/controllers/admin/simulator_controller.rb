
class Admin::SimulatorController < AdminController
  class NotAllowed < StandardError
  end
  
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

    pending = find_scheduled_messages.map {|m|
      { to: true,
        at: m.scheduled_at,
        message: m.message_or_question_text,
        pending: true
      }}

    @messages = (to + from + pending).sort_by {|m| m[:at]}
  end

  def simulate_send
    raise NotAllowed unless current_survey.development_mode
    # fake-send current scheduled message
    m = find_scheduled_messages.first
    unless m then
      current_survey.schedule_participant! current_participant
      redirect_to action: "index"
    else
      m.mark_delivered
      m.save!

      # Do replacement in message
      message = ParticipantTexter.do_replacements(
        m.message_or_question_text,
        ParticipantTexter.build_replacements(
          current_participant, m))

      OutgoingTextMessage.create!(
        survey: current_survey,
        from_number: current_survey.phone_number,
        to_number: current_participant.phone_number,
        message: message,
        simulated: true,
        scheduled_at: m.scheduled_at,
        delivered_at: m.scheduled_at
      )
      
      # now we reschedule next message for participant
      current_survey.schedule_participant! current_participant
      redirect_to action: "index"
    end
  end

  def simulate_timeout
    raise NotAllowed unless current_survey.development_mode
    # TODO: Not sure how to cause the state machine to timeout
    redirect_to action: "index"
  end

  def simulate_reply
    raise NotAllowed unless current_survey.development_mode
    message = params[:reply]
    # fake a text message from the participant
    IncomingTextMessage.create!(
      survey: current_survey,
      from_number: current_participant.phone_number,
      to_number: current_survey.phone_number,
      message: message,
      simulated: true,
      delivered_at: Time.now
    )

    # feed this input to survey state machine, if available
    if current_participant.participant_state.respond_to? :incoming_message then
      current_participant.participant_state.incoming_message message
    end

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
