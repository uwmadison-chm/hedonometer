# -*- encoding : utf-8 -*-
require 'test_helper'

class ParticipantTexterTest < ActiveSupport::TestCase
  test "welcome message does replacements" do
    ppt = participants(:ppt1)
    otm = ParticipantTexter.welcome_message(ppt)
    assert_includes otm.message, ppt.login_code
  end

  test "login message does replacements" do
    ppt = participants(:ppt1)
    otm = ParticipantTexter.login_code_message(ppt)
    assert_includes otm.message, ppt.login_code
  end

  test "date replacements" do
    ppt = participants(:ppt1)
    otm = ParticipantTexter.message_with_replacements(
      "{{first_date}} {{last_date}}", ppt)
    assert_equal otm.message, "#{Date.today.to_s(:for_sms)} #{Date.tomorrow.to_s(:for_sms)}"
  end

  test "questions do replacements" do
    twilio_mock(TwilioResponses.create_sms)
    ppt = participants(:ppt1)
    question = survey_questions(:test_replace)
    sday = schedule_days(:test_day_1)
    scheduled = ScheduledQuestion.create!(
      :schedule_day => sday,
      :survey_question => question,
      :scheduled_at => 1.minute.ago
    )
    ParticipantTexter.deliver_scheduled_question!(scheduled.id)
    assert_equal ppt.external_key, ppt.text_messages.first.message
  end
end