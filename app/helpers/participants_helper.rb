# -*- encoding : utf-8 -*-

module ParticipantsHelper
    def day_length_string(total_minutes)
        hours = (total_minutes/60).to_i
        minutes = total_minutes%60
        minutes_string = ''
        if minutes > 0
            minutes_string = ' '+pluralize(minutes, 'minute')
        end
        "#{pluralize(hours, 'hour')}#{minutes_string}"
    end

    def allow_texting_check_box(form)
      if form.object.active?
        form.check_box :active, label: "Allow texts to this participant."
      else
        form.right_content "Stopped. To restart, have participant text START to #{form.object.survey.phone_number.humanize}."
      end
    end
end
