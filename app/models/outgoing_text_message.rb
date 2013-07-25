class OutgoingTextMessage < TextMessage

  def deliver!
    t = Time.now
    self.scheduled_at ||= t
    self.delivered_at = t
    response = survey.sms_target.create({
      to: self.to,
      from: self.from,
      body: self.message
    })
  end

  def deliver_and_save!
    deliver! and save!
  end
end