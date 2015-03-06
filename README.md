# hedonometer

## Background

A simple Rails-based web application for collecting experience sampling data via text message.

Much of traditional psychology research involves bring participants to the lab and having them fill out various questionnaires. Then, researchers correlate their questionnaire answers with other data acquired in the lab.

The big problem with this is: how do we know whether peoples' behavior in the lab is anything like their behavior in the "real world?" Experience sampling tries to get at this by collecting data while participants are out of the lab, engaging in their normal activity.

Many variants on experience sampling exist; however, extant ones tend to rely either on specialized hardware and/or software, or online connectivity.  hedonometer differs in that participants are prompted for and send data purely by text message. Hence, people need only have a cell phone to participate.


## Requirements

This is written and tested in Ruby 2.2.0. Probably it'll work with 1.9, but really, I'm planing to stay edge.

## Getting Started

Installing this is the same as installing any Rails app. Clone, `bundle install`, `rake db:migrate`. There isn't yet a rake task to add your first admin, so pull up a Rails console and:

```
Admin.create(email: "your_email@example.com", password: "some-password", can_change_admins: true)
```

Fire up a server and you're in. For this to accept incoming texts, you'll need a publicly accessible server.

At the same time, head over to [Twilio](http://twilio.com) and get yourself an account. Either sign up for a trial number and register your moblie number with it, or buy some credits.

On the numbers screen, note your Twilio Account SID and your Authorization Token.

Back in the hedonometer, create a survey. Paste in your Account SID and Auth Token; you should get a little "Active" status light. The "Phone number" field should autocomplete with the number you've purchased.

Play around a bit.