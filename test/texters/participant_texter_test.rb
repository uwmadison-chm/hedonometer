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
end