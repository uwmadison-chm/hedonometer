class OutgoingTextMessage < TextMessage
  attr_accessor :twilio_message

  SUCCESS_STATUSES = %w(queued sending sent)

  def delivered_successfully?
    @twilio_message and SUCCESS_STATUSES.include? @twilio_message.status
  end

  def deliver!
    t = Time.now
    self.scheduled_at ||= t
    client = survey.twilio_client
    @twilio_message = client.account.sms.messages.create({
      to: self.to,
      from: self.from,
      body: self.message
    })
    self.server_response = JSON.parse(client.last_response.body)
    if not self.delivered_successfully?
      raise DeliveryError.new("Text message delivery failed!")
    end
    self.delivered_at = t
  end

  def deliver_and_save!
    deliver! and save!
  end
end