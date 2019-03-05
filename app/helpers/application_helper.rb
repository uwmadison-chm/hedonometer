# -*- encoding : utf-8 -*-

module ApplicationHelper
  def absolute_url_for(options = {})
      url_for(options.merge({:only_path => false}))
  end

  def humanize_phone_number(numberlike)
    PhoneNumber.new(numberlike.to_s).humanize
  end
end
