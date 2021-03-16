class IncomingTextMessagesController < SurveyedController

  skip_before_action :verify_authenticity_token
  skip_before_action :require_participant_login!

  before_action :underscorify_params!

  # NOTE: Currently, Twilio does its own STOP/HELP messages, and you can't 
  # override them or change them. See:
  # https://support.twilio.com/hc/en-us/articles/223134027-Twilio-support-for-opt-out-keywords-SMS-STOP-filtering-

  ROUTING_TABLE = [
    [/^(STOP|END|QUIT|CANCEL|UNSUBSCRIBE)/i, :handle_stop],
    [/^(START)/i, :handle_start],
    [/^(HELP|INFO|\?)/i, :handle_help],
  ]

  def create
    logger.debug "Incoming text message for survey #{current_survey}: #{params.inspect}"
    itm = current_survey.incoming_text_messages.create!(
      to_number: params[:to],
      from_number: params[:from],
      message: params[:body],
      server_response: params)
    method = lookup_route(itm.message)
    if method
      # If it's a standard message, we respond to it here
      self.send method, itm
    else
      # otherwise send it through to the state for this participant
      ppt = participant_from_phone_number(params[:from])
      if not ppt or not ppt.participant_state
        logger.warn("Could not find participant for survey #{current_survey.id}, " +
                    "check that the callback URL in Twilio is set correctly if you have " +
                    "multiple surveys connected to one Twilio account.")
      elsif ppt.participant_state.respond_to? :incoming_message
        ppt.participant_state.incoming_message params[:body]
      else
        logger.info "Ignored text message: #{params.inspect}"
      end
    end
    head :ok
  end

  protected
  def lookup_route(message_content)
    entry = ROUTING_TABLE.find {|entry|
      entry[0] =~ message_content
    }
    entry[1] if entry
  end

  def handle_stop(message)
    # NOTE: we currently cannot handle these messages, they are trapped by 
    # Twilio and not passed through
    ppt = set_participant_active(params[:from], false)
    if ppt
      ParticipantTexter.stop_message(ppt).deliver_and_save!
    end
  end

  def handle_start(message)
    ppt = set_participant_active(params[:from], true)
    if ppt
      ParticipantTexter.start_message(ppt).deliver_and_save!
    end
  end

  def handle_help(message)
    # NOTE: we currently cannot handle these messages, they are trapped by 
    # Twilio and not passed through
    ppt = participant_from_phone_number 
    if ppt
      ParticipantTexter.help_message(ppt).deliver_and_save!
    end
  end

  def participant_from_phone_number(number)
    if not current_survey
      logger.warn "No current survey when trying to parse incoming text message"
    end
    ppt = current_survey.participants.where(phone_number: number).first
    if not ppt
      logger.warn "Could not find {number} on survey {current_survey}"
    end
    ppt
  end

  def set_participant_active(phone_number, active_value)
    ppt = participant_from_phone_number(phone_number)
    if ppt
      ppt.active = active_value
      ppt.save!
    end
    ppt
  end

  def underscorify_params!
    orig_keys = params.keys
    orig_keys.each do |old_key|
      new_key = old_key.underscore
      params[new_key] = params.delete(old_key) unless params.include? new_key
    end
  end

  def incoming_text_message_params
    params.permit(:to, :from, :body)
  end
end
