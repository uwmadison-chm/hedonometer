class Survey < ActiveRecord::Base
  attr_accessor :creator

  has_many :survey_permissions
  has_many :admins, through: :survey_permissions

  has_many :survey_questions

  validates :creator, presence: true, on: :create
  validates :name, presence: true
  validates :samples_per_day, numericality: {only_integer: true, greater_than: 0}
  validates :mean_minutes_between_samples,
    numericality: {only_integer: true, greater_than: 0}
  validates :sample_minutes_plusminus,
    numericality: {only_integer: true, greater_than: 0}

  after_create :assign_creator_as_admin

  private
  def assign_creator_as_admin
    self.survey_permissions.create admin: creator, can_modify_survey: true
  end
end
