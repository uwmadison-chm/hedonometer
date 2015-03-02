# -*- encoding : utf-8 -*-
class Admin::SurveysController < AdminController
  before_action :find_survey, only: [:edit, :update, :show]
  after_action :set_twilio_errors_flash, only: [:update, :create]

  def new
    @survey = Survey.new
    @survey.survey_questions.build
  end

  def show
    respond_to do |format|
      format.csv {render layout: false}
    end
  end

  def edit
    @survey.survey_questions.build if @survey
  end

  def update
    if @survey.update_attributes survey_params
      message_url = survey_message_url(survey_id: @survey)
      logger.debug "Setting survey handler URL to #{message_url}"
      @survey.set_twilio_number_handlers! message_url
      redirect_to edit_admin_survey_path(@survey)
    else
      render action: :edit
    end
  end

  def create
    @survey = Survey.create survey_params.merge(creator: current_admin)
    render action: :new and return if @survey.new_record?
    message_url = survey_message_url(survey_id: @survey)
    logger.debug "Setting survey handler URL to #{message_url}"
    @survey.set_twilio_number_handlers! message_url
    redirect_to edit_admin_survey_path(@survey)
  end

  private
  def set_twilio_errors_flash
    flash[:twilio_errors] = @survey.twilio_errors
    logger.debug("Setting flash[:twilio_errors] to #{flash[:twilio_errors]}")
  end

  def find_survey
    @survey = current_admin.surveys.modifiable.where(id:params[:id]).first
  end

  def survey_params
    params.
      require(:survey).
      permit(
        :name,
        :sampled_days,
        :samples_per_day,
        :mean_minutes_between_samples,
        :sample_minutes_plusminus,
        :active,
        :twilio_account_sid,
        :twilio_auth_token,
        :phone_number,
        :help_message,
        :time_zone,
        :welcome_message,
        :survey_questions_attributes => [:id, :question_text])
  end
end
