# -*- encoding : utf-8 -*-
class Admin < ApplicationRecord
  attr_accessor :password
  attr_accessor :deactivate

  before_save :encrypt_password

  validates :email, uniqueness:true

  scope :active, -> { where("deleted_at IS NULL").order("email") }
  scope :inactive, -> { where("deleted_at IS NOT NULL").order("email") }

  has_many :survey_permissions
  has_many :surveys, :through => :survey_permissions do
    def modifiable
      where("survey_permissions.can_modify_survey" => true)
    end
  end

  def can_modify_survey?(survey)
    self.surveys.modifiable.where("survey_permissions.survey_id" => survey).first
  end

  def active=(val)
    return if val.blank?
    if val.to_s == "0"
      self.deleted_at = Time.now
    else
      self.deleted_at = nil
    end
  end

  def active
    self.deleted_at.nil?
  end
  alias_method :active?, :active

  def password_match?(pw)
    self if (
      password_hash.present? and
      password_hash == BCrypt::Engine.hash_secret(pw, password_salt))
  end

  class << self
    def authenticate(email, password)
      a = where(email:email).first
      a and a.password_match? password
    end
  end

  private
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end
