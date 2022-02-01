class ScheduledMessagesController < SurveyedController
  layout 'participant'

  # Don't require login, we just need to redirect people to a link
  skip_before_action :require_participant_login!

  def show
    message = ScheduledMessage.find_by_id params[:id]
    if message
      # Set this for views so they can show survey's help message
      @current_survey = message.schedule_day.participant.survey

      # How old are we? If too old, show expired message
      # Default to scheduled time + 30 minutes if no explicit time
      expires_at = message.expires_at || (message.scheduled_at + @current_survey.message_expiration_minutes.minutes)
      if Time.now > expires_at then
        @expired_string = "This link expired #{helpers.time_ago_in_words(expires_at)} ago."
        render "expired"
      else
        @expired_string = nil
        if not message.destination_url
          render "expired", status: :not_found
          return false
        else
          redirect_to message.destination_url
        end
      end
    else
      render "expired", status: :not_found
      return false
    end
  end

  def complete
  end
end

