require 'ostruct'

class ParticipantState < OpenStruct
  include ActiveModel::Model
  include ActiveModel::Attributes
  include AASM

  attribute :information, :string
  attribute :aasm_state, :string

  # Table and modifiable are assumed by something inside rails - ignore for now
  attribute :table, :string
  attribute :modifiable, :string

  aasm do
    state :none, initial: true
  end

end

class ParticipantStateType < ActiveModel::Type::Value
  # This pattern is originally from 
  # https://dev.to/evilmartians/wrapping-json-based-activerecord-attributes-with-classes-4apf
  # If we start to do this a lot, consider using his store_model gem:
  # https://github.com/DmitryTsepelev/store_model

  def type
    :jsonb
  end

  def cast_value(value)
    case value
    when String
      decoded = ActiveSupport::JSON.decode(value) rescue nil
      # ???
      kls = decoded['class']
      ParticipantState.new(decoded) unless decoded.nil?
    when Hash
      ParticipantState.new(value)
    else
      value
    end
  end

  def serialize(value)
    if value.kind_of? ParticipantState or value.kind_of? Hash
      # TODO: Ensure class is embedded here somehow
      ActiveSupport::JSON.encode(value)
    else
      super
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    cast_value(raw_old_value) != new_value
  end
end
