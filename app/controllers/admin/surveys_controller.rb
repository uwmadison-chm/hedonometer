# -*- encoding : utf-8 -*-
class Admin::SurveysController < AdminController
  before_action :find_survey, only: [:edit, :update, :download]

  def new
    @survey = Survey.new
    @survey.survey_questions.build
  end

  def download
    respond_to do |format|
      format.csv {
        render text: @survey.to_csv
      }
    end
  end

  def edit
    @survey.survey_questions.build if @survey
  end

  def update
    if @survey.update_attributes survey_params
      redirect_to edit_admin_survey_path(@survey)
    else
      render action: :edit
    end
  end

  def create
    @survey = Survey.create survey_params.merge(creator: current_admin)
    render action: :new and return if @survey.new_record?
    redirect_to edit_admin_survey_path(@survey)
  end

  private
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
        :survey_questions_attributes => [:id, :question_text])
  end
end
