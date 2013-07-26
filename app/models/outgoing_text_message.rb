class OutgoingTextMessage < TextMessage
  attr_accessor :twilio_message

  def deliver!
    t = Time.now
    self.scheduled_at ||= t
    self.delivered_at = t
    client = survey.twilio_client
    @twilio_message = client.account.sms.messages.create({
      to: self.to,
      from: self.from,
      body: self.message
    })
    self
  end

  def deliver_and_save!
    deliver! and save!
  end
end