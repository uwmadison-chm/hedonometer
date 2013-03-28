class Admin::SurveysController < AdminController
  before_filter :find_survey, only: [:edit, :create]

  def new
    @survey = Survey.new
  end

  def edit

  end

  private
  def find_survey
    @survey = current_admin.surveys.modifiable.where(id:params[:id]).first
  end
end
