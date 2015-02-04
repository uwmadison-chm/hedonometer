# -*- encoding : utf-8 -*-
require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  test "replacement system" do
    msg = "{{foo}} bar"
    rep_hash = {'{{foo}}' => "eat the"}
    out = ActionTexter::Base.do_replacements(msg, rep_hash)
    assert_equal out, "eat the bar"
  end
end