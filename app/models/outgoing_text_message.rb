class OutgoingTextMessage < TextMessage
  attr_accessor :twilio_message

  SUCCESS_STATUSES = %w(queued sending sent)

  def direction
    'outgoing'
  end

  def delivered_successfully?
    @twilio_message and SUCCESS_STATUSES.include? @twilio_message.status
  end

  def participant
    survey.participants.find_by_phone_number(self.to_number.to_s)
  end

  def deliver!
    t = Time.now
    self.scheduled_at ||= t
    # We only actually send the message if config.texting is set to twilio
    if Rails.application.config.texting == :twilio then
      logger.debug("config.texting is set to #{Rails.application.config.texting}, sending message '#{self.message}' from '#{self.from_number}' to '#{self.to_number}'")
      client = survey.twilio_client
      @twilio_message = client.account.sms.messages.create({
        to: self.to_number,
        from: self.from_number,
        body: self.message
      })
      self.server_response = JSON.parse(client.last_response.body)
      if not self.delivered_successfully?
        raise DeliveryError.new("Text message delivery failed!")
      end
    else
      logger.debug("Would send message '#{self.message}' from '#{self.from_number}' to '#{self.to_number}'")
    end
    self.delivered_at = t
  end

  def deliver_and_save!
    deliver! and save!
  end
end
