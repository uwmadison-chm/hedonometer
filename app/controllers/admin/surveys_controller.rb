class Admin::SurveysController < AdminController
  before_filter :find_survey, only: [:edit, :update]

  def new
    @survey = Survey.new
  end

  def edit
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
        :samples_per_day,
        :mean_minutes_between_samples,
        :sample_minutes_plusminus,
        :active,
        :survey_questions_attributes => [:id, :question_text])
  end
end
