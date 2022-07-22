# hedonometer

## Background

A simple Rails-based web application for collecting experience sampling data via text message.

Much of traditional psychology research involves bring participants to the lab and having them fill out various questionnaires. Then, researchers correlate their questionnaire answers with other data acquired in the lab.

The big problem with this is: how do we know whether peoples' behavior in the lab is anything like their behavior in the "real world?" Experience sampling tries to get at this by collecting data while participants are out of the lab, engaging in their normal activity.

Many variants on experience sampling exist; however, extant ones tend to rely either on specialized hardware and/or software, or online connectivity.  hedonometer differs in that participants are prompted for and send data purely by text message. Hence, people need only have a cell phone to participate.


## Requirements

This was written and tested in Ruby 2.2.0, and then upgraded to 2.6.1.


## Getting Started

Development prerequisites:

    sudo apt install postgresql libpq-dev nodejs

(or any other [ExecJS](https://github.com/rails/execjs) runtime)

Installing this is the same as installing any Rails app. Clone, `bundle install`, `rake db:migrate`.

## Database

Recently switched to postgres in devel to avoid a weird json blob problem in sqlite.

There's likely a cleaner way, but per environment, do something like:

    sudo apt install postgresql libpq-dev
    sudo -u postgres psql

    create database hedonometer_development;
    create user myuser with encrypted password '123';
    grant all privileges on database hedonometer_development to myuser;

    create database hedonometer_test;
    grant all privileges on database hedonometer_test to myuser;

    create database hedonometer_production;
    grant all privileges on database hedonometer_production to myuser;

Then copy `config/database.yml.example` to `config/database.yml` and edit it 
to match.

Now you should be able to migrate the db:

    bin/rails db:migrate

## Configuring admins

There isn't yet a rake task to add your first admin, so pull up `rails console` and:

    Admin.create(email: "your_email@example.com", password: "some-password", can_change_admins: true)

`rails server` and you're in. For this to accept incoming texts, you'll need a publicly accessible server.

### Adding multiple admins to a survey

    a = Admin.find(admin_id)
    a.surveys.append(Survey.find(survey_id))

Not sure how to force the `can_modify_survey` for secondary admins:

    a.survey_permissions.each do |perm|
      perm.can_modify_survey = true
      perm.save
    end

## Twilio config

At the same time, head over to [Twilio](http://twilio.com) and get yourself an account. Either sign up for a trial number and register your mobile number with it, or buy some credits.

On the numbers screen, note your Twilio Account SID and your Authorization Token.

## Survey creation

Back in the hedonometer, create a survey. Paste in your Account SID and Auth Token; you should get a little "Active" status light. The "Phone number" field should autocomplete with the number you've purchased.

Further documentation about different survey types is in [doc/](doc/).


## Development

### Ubuntu packages required for development

    sudo apt-get install libpq-dev libmysqlclient-dev nodejs

### Delayed jobs in dev

By default, texting is log-only and doesn't hit Twilio in dev.

Start a daemon:

    bin/delayed_job start

Start a server. Now you can use the website, add surveys and participants, and 
the simulator and message lists should show what "would have" happened.
