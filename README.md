# hedonometer

## Background

A simple Rails-based web application for collecting experience sampling data via text message.

Much of traditional psychology research involves bring participants to the lab and having them fill out various questionnaires. Then, researchers correlate their questionnaire answers with other data acquired in the lab.

The big problem with this is: how do we know whether peoples' behavior in the lab is anything like their behavior in the "real world?" Experience sampling tries to get at this by collecting data while participants are out of the lab, engaging in their normal activity.

Many variants on experience sampling exist; however, extant ones tend to rely either on specialized hardware and/or software, or online connectivity.  hedonometer differs in that participants are prompted for and send data purely by text message. Hence, people need only have a cell phone to participate.

_TODO:_ add references

## Components

hedonometer has two main parts: a participant-facing application (accessed mainly or only by text message), and a web-based interface for researches to set up surveys.

### Participants!

Participants sign in to the app by texting "signup" to your assigned phone number. The app will respond by asking for the participant's email address. Upon providing that, the app will send the participant a researcher-specified "welcome" email. This ensures that participants can both send and recieve text messages from the app.

The reseacher will schedule an intake with the participant as normal, and the researcher will set a start and end date for the data collection period. (Maybe) the participant will choose days and time periods when they will be unavailable for data collection.

During the data colleciton period, participants will receive texts at researcher-specified intervals and respond. At any point, participants can text "stop" or "unsubscribe" to cancel (as per relevant laws regarding text message services).

### Researchers!

Workflow for researchers will be similar to:

1. Create an account on Twilio, buy a number there
1. In hedonometer, add your twilio Account SID and auth token
1. hedonometer will find your phone number
1. In the admin interface, add one (or more?) questions to your survey
1. Choose a number of days for collection, also hours, and maybe "valid" start and end times
1. Validate participants and set a start date for them.
1. Download data!

### Randomization

If a survey contains multiple questions, researchers will have three message ordering strategies. Assuming your survey has questions A, B, and C, you'll be able to order messages by:

* Round robin: ABC ABC ABC ABC ABC ...
* Random without replacement: CAB BAC ABC CAB ACB BCA ...
* Random with replacement: CAA BAC CBB AAA CBA AAB ...