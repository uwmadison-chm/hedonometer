class ScheduledMessagesController < SurveyedController
  layout 'participant'

  # Don't require login
  skip_before_action :require_participant_login!

  def show
    message = ScheduledMessage.find_by_id params[:id]
    if message
      # Set this for views
      @current_survey = message.schedule_day.participant.survey

      # How old are we? If too old, show expired message
      if message.scheduled_at > 30.minutes then
        @expired_string = "This link expired #{helpers.time_ago_in_words(message.scheduled_at + 30.minutes)} ago."
        render "expired"
      else
        @expired_string = nil
        redirect_to @current_survey.something
      end
    else
      render "expired", status: :not_found
      return false
    end
  end
end

