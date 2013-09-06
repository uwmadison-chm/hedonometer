# -*- encoding : utf-8 -*-

module ApplicationHelper
  def humanize_phone_number(numberlike)
    PhoneNumber.new(numberlike.to_s).humanize
  end

  def grid_if_development
    'grid' if Rails.env.development?
  end
end
