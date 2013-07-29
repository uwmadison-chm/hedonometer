class IncomingTextMessage < TextMessage
  before_validation :set_delivered_at, on: :create
  validate :survey_phone_number_matches_to_phone_number

  protected
  def set_delivered_at
    self.delivered_at = Time.now
  end

  def survey_phone_number_matches_to_phone_number
    if survey.phone_number != self.to
      errors.add(:to, "must match survey number (#{survey.phone_number})")
    end
  end
end