module Admin::ParticipantsHelper
  def number_with_external_key(ppt)
    num = "#{ppt.phone_number.humanize}"
    num += " [#{ppt.external_key}]" if ppt.external_key.present?
  end
end
