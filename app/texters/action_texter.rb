module ActionTexter
  class Base < AbstractController::Base
    class << self

      def do_replacements(message, replacements)
        msg_out = message.dup
        replacements.each do |target, replacement|
          msg_out.gsub! target, replacement.to_s
        end
        msg_out
      end
    end
  end
end