# -*- encoding : utf-8 -*-

module ApplicationHelper
  def humanize_phone_number(numberlike)
    PhoneNumber.new(numberlike.to_s).humanize
  end
end
