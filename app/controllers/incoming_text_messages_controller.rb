class IncomingTextMessagesController < SurveyedController

  skip_before_action :verify_authenticity_token
  skip_before_action :require_participant_login!

  before_action :underscorify_params!

  def create
    logger.debug "Incoming text message: #{params.inspect}"
    itm = current_survey.incoming_text_messages.create!(
      to: params[:to],
      from: params[:from],
      message: params[:body],
      server_response: params)
    if itm.message.downcase == 'stop'
      # Find the ppt and deactivate
      # Todo: test this
      ppt = current_survey.participants.where(phone_number: params[:from]).first
      if ppt
        ppt.active = false
        ppt.save
      end
    end
    render nothing: true
  end

  protected
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
