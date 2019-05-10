require 'ostruct'

class ParticipantState < OpenStruct
  include AASM

  def current_state
    if @aasm
      @aasm.current_state
    else
      :none
    end
  end

  def hash
    (super.to_s + current_state.to_s).hash
  end

  aasm column: 'aasm_state' do
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
    if value.kind_of? ParticipantState
      return value
    end

    case value
    when String
      hash = ActiveSupport::JSON.decode(value) rescue nil
    when Hash
      hash = value
    end

    # ActiveModel::Type wraps things in a weird way sometimes?
    if hash.key? 'table'
      hash = hash['table']
    end
    if hash['klass']
      kls = hash['klass'].constantize
    else
      kls = ParticipantState
    end
    aasm_state = hash['aasm_state']
    hash.delete 'aasm_state'
    result = kls.new(hash)
    if aasm_state
      if result.aasm.respond_to? :current_state=
        result.aasm.current_state = aasm_state.intern
      else
        raise "Could not set state on #{result.inspect}"
      end
    end
    result
  end

  def serialize(value)
    if value.kind_of? ParticipantState or value.kind_of? Hash
      hash = value.to_h
      # Embed class name, kinda ugly
      hash['klass'] = value.class.to_s
      # Embed aasm state name so we can resurrect it
      aasm_state = value.try(:aasm).try(:current_state)
      hash['aasm_state'] = aasm_state
      ActiveSupport::JSON.encode(hash)
    else
      raise "Should only serialize ParticipantState objects"
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    old = cast_value(raw_old_value)
    old.hash != new_value.hash
  end
end
