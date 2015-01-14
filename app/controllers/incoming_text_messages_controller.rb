class IncomingTextMessagesController < SurveyedController

  skip_before_action :verify_authenticity_token
  skip_before_action :require_participant_login!

  before_action :underscorify_params!

  ROUTING_TABLE = [
    [/STOP/i,     :handle_stop],
    [/START/i,    :handle_start]
  ]

  def create
    logger.debug "Incoming text message: #{params.inspect}"
    itm = current_survey.incoming_text_messages.create!(
      to_number: params[:to],
      from_number: params[:from],
      message: params[:body],
      server_response: params)
    method = lookup_route(itm.message)
    if method
      self.send method, itm
    end
    render nothing: true
  end

  protected
  def lookup_route(message_content)
    entry = ROUTING_TABLE.find {|entry|
      entry[0] =~ message_content
    }
    entry[1] if entry
  end

  def handle_stop(message)
    set_participant_active(params[:from], false)
  end

  def handle_start(message)
    set_participant_active(params[:from], true)
  end

  def set_participant_active(phone_number, active_value)
    ppt = current_survey.participants.where(phone_number: phone_number).first
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
