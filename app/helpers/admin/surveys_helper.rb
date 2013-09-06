# -*- encoding : utf-8 -*-

module Admin::SurveysHelper
  def survey_help_with_default(survey)
    survey.help_message or "Need help? Contact your study administrator at #{mail_to current_admin.email}."
  end
end
