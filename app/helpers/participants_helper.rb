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
end
