class Survey < ActiveRecord::Base
  attr_accessor :creator
  attr_accessor :phone_number

  has_many :survey_permissions
  has_many :admins, through: :survey_permissions
  has_one :twilio_number

  has_many :survey_questions
  accepts_nested_attributes_for :survey_questions

  has_many :participants

  validates :name, presence: true
  validates :samples_per_day, numericality: {only_integer: true, greater_than: 0}
  validates :mean_minutes_between_samples, numericality: {only_integer: true, greater_than: 0}
  validates :sample_minutes_plusminus, numericality: {only_integer: true, greater_than: 0}

  validates :creator, on: :create, presence: true
  after_create :assign_creator_as_admin

  private
  def assign_creator_as_admin
    self.survey_permissions.create admin: creator, can_modify_survey: true
  end
end
