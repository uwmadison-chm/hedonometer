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
    assert_equal "#{Date.today.to_s(:for_sms)} #{Date.tomorrow.to_s(:for_sms)}", otm.message
  end

  test "questions do replacements" do
    twilio_mock(TwilioResponses.create_sms)
    ppt = participants(:ppt1)
    question = survey_questions(:test_replace)
    sday = schedule_days(:test_day_1)
    scheduled = ScheduledMessage.create!(
      :schedule_day => sday,
      :survey_question => question,
      :scheduled_at => 1.minute.ago
    )
    ParticipantTexter.deliver_scheduled_message!(scheduled.id)
    assert_equal ppt.external_key, ppt.text_messages.first.message
  end

  test "messages do replacements" do
    twilio_mock(TwilioResponses.create_sms)
    ppt = participants(:ppt4)
    sday = schedule_days(:ppt4_test_day_1)
    scheduled = ScheduledMessage.create!(
      :schedule_day => sday,
      :message_text => "{{external_key}}",
      :scheduled_at => 1.minute.ago
    )
    ParticipantTexter.deliver_scheduled_message!(scheduled.id)
    assert_equal ppt.external_key, ppt.text_messages.first.message
  end
end
