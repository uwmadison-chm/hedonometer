
class Admin::SimulatorController < AdminController
  def index
    if !current_participant
      not_found
    end

    @page_title = "Simulator for participant #{current_participant.external_key}"

    @messages = [
      { to: true,
        at: Time.now - 3.days,
        message: "Here, take this survey!"
      },
      { to: false,
        at: Time.now - 2.5.days,
        message: "What?"
      },
      { to: true,
        at: Time.now - 2.days,
        message: "Here, take this survey!"
      },
      { to: true,
        at: Time.now - 1.5.days,
        message: "Here, take this survey!"
      },
      { to: true,
        at: Time.now - 1.25.days,
        message: "Here, take this survey!"
      },
      { to: true,
        at: Time.now - 8.hours,
        message: "Here, take this survey!"
      },
      { to: false,
        at: Time.now - 7.hours,
        message: "no dangit jeeeeez"
      },
      { to: true,
        at: Time.now - 6.hours,
        message: "Here, take this survey!"
      },
      { to: true,
        at: Time.now - 40.minutes,
        message: "Here, take this wacky survey!"
      },
      { to: false,
        at: Time.now - 38.minutes,
        message: "HELP!"
      },
      { to: false,
        at: Time.now - 37.minutes,
        message: "I don't understand"
      },
      { to: true,
        at: Time.now - 9.minutes,
        message: "Would you like to play a game?"
      },
      { to: true,
        at: Time.now - 8.minutes,
        message: "Would you like to play a game???"
      },
      { to: false,
        at: Time.now - 7.minutes,
        message: "NO. Leave me alone! I am gonna have to complain to the FCC or something! Dang."
      },
    ]
  end
 
  def current_participant
    @participant ||= Participant.find_by_id(params[:participant_id])
  end
  helper_method :current_participant
end
